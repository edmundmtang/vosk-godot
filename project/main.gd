extends Node2D

onready var recording_player = $Recording_Player


var VoskRecognizerSource = load("res://bin/gdvosk.gdns")
var voice_recognizer = VoskRecognizerSource.new()
var audio_mix_rate: float = ProjectSettings.get_setting("audio/mix_rate")

var record_effect: AudioEffectRecord
var capture_effect: AudioEffectCapture
var recording: AudioStreamSample # To Do - might be unnecessary
var is_recording: bool = false
var audio_buffer := StreamPeerBuffer.new()
var block_size: int = 1024
var buffer_cursor := 0

var phoneme: String
var partial_result: String
var final_result: String

var sampling_timer: float = 0.0
var sampling_delay := 0.04 # Do not set to under 0.03?

var lm: Dictionary = {
	small_en = "language_models/vosk-model-small-en-us-0.15",
	en = "language_models/vosk-model-en-us-0.22", # likely too big
	daanzu = "language_models/vosk-model-en-us-daanzu-20200905" # approximately too big
}

func _ready():
	print("Starting Test!")
	voice_recognizer.initialize(
		lm.small_en, # model_path
		48000 # audio_mix_rate # sample rate
		)
	print("Model path: ", voice_recognizer.model_path)
	print("Sample rate: ", voice_recognizer.sample_rate)
	record_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index('Record'), 0)
	capture_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index('Record'), 1)
	$Test_HUD.connect("record_toggled", self, "_on_record_button_toggle")
	voice_recognizer.set_result_options("phones")
	print('End of Test Initialization\n')

func _on_record_button_toggle() -> void:
	if is_recording:
		stop_recording()
	else:
		start_recording()

func start_recording() -> void:
	print("Microphone on")
	is_recording = true
	record_effect.set_recording_active(is_recording)

func stop_recording() -> void:
	print("Microphone off")
	is_recording = false
	record_effect.set_recording_active(is_recording)
	sampling_timer = 0

	print("Buffer_size: ", audio_buffer.get_size())
	print(voice_recognizer.get_final())
	buffer_cursor = 0
	audio_buffer.clear()

func _process(delta):
	if is_recording:
		sampling_timer += delta
		if sampling_timer > sampling_delay:
			queue_audio_data()
			pass_audio_data()
			sampling_timer = 0
			print(voice_recognizer.get_partial())

func queue_audio_data() -> void:
	# To-Do: This works, but conceptually sucks. It really should use an actual stream or buffer,
	# maybe AudioStreamCapture could do the job, but it's Vector2...
	record_effect.set_recording_active(false)
	audio_buffer.put_data(record_effect.get_recording().data)
	record_effect.set_recording_active(true)

func pass_audio_data() -> void:
	while buffer_cursor + block_size < audio_buffer.get_size():
		audio_buffer.seek(buffer_cursor)
		var subsample = audio_buffer.get_data(block_size)[1]
		voice_recognizer.accept_waveform(subsample, block_size)
		buffer_cursor += block_size
