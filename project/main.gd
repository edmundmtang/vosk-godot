extends Node2D

onready var recording_player = $Recording_Player


var VoskRecognizerSource = load("res://bin/gdvosk.gdns")
var voice_recognizer = VoskRecognizerSource.new()
var audio_mix_rate: float = ProjectSettings.get_setting("audio/mix_rate")


var is_recording: bool = false

var block_size: int = 4096
var buffer_cursor := 0

var phoneme: String
var partial_result: String
var final_result: String

var sampling_timer: float = 0.0
var sampling_delay := 0.5 # Do not set to under 0.03?

var lm: Dictionary = {
	small_en = "language_models/vosk-model-small-en-us-0.15",
	en = "language_models/vosk-model-en-us-0.22", # likely too big
	daanzu = "language_models/vosk-model-en-us-daanzu-20200905" # approximately too big
}

func _ready():
	print("Starting Test!")

	var load_voice_rec = false
	if load_voice_rec:
		voice_recognizer.initialize(
			lm.small_en, # model_path
			48000 # audio_mix_rate # sample rate
			)
		var result_option := "phones"
		voice_recognizer.set_result_options("phones")

		print("Model path: ", voice_recognizer.model_path)
		print("Sample rate: ", voice_recognizer.sample_rate)
		print("Buffer_size: ", voice_recognizer.buffer_size())
		print("Result option: ", result_option)

	$Test_HUD.connect("record_toggled", self, "_on_record_button_toggle")

	print('End of Test Initialization\n')

func _on_record_button_toggle() -> void:
	if recording_player.record_effect.is_recording_active():
		stop_recording()
	else:
		start_recording()

func start_recording() -> void:
	print("Microphone on")
	recording_player.start_recording()

func stop_recording() -> void:
	print("Microphone off")
	recording_player.stop_recording()

	var final_output = voice_recognizer.get_final()
	print(final_output)
	print(JSON.parse(final_output).get_result()["text"])
	buffer_cursor = 0

func _process(delta):
	pass

func pass_audio_data():
	voice_recognizer.accept_waveform(recording_player.audio_buffer.get_data(block_size)[1])




"""
func queue_audio_data() -> void:
	# To-Do: This works, but conceptually sucks. It really should use an actual stream or buffer,
	# maybe AudioStreamCapture could do the job, but it's Vector2...
	record_effect.set_recording_active(false)
	audio_buffer.put_data(record_effect.get_recording().data)
	print(audio_buffer.get_size())
	record_effect.set_recording_active(true)

func pass_audio_data() -> void:
	while buffer_cursor + block_size < audio_buffer.get_size():
		audio_buffer.seek(buffer_cursor)
		var subsample = audio_buffer.get_data(block_size)[1]
		buffer_cursor += block_size
		voice_recognizer.accept_waveform(subsample, block_size)

"""
