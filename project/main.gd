extends Node2D

onready var recording_player = $Recording_Player


var VoskRecognizerSource = load("res://bin/gdvosk.gdns")
var voice_recognizer = VoskRecognizerSource.new()
var audio_mix_rate: float = ProjectSettings.get_setting("audio/mix_rate")


var block_size: int = 4096

var buffer = StreamPeerBuffer.new()

var phoneme: String
var partial_result: String
var final_result: String

var lm: Dictionary = {
	small_en = "language_models/vosk-model-small-en-us-0.15",
	en = "language_models/vosk-model-en-us-0.22", # likely too big
	daanzu = "language_models/vosk-model-en-us-daanzu-20200905" # approximately too big
}

func _ready():
	print("Starting Test!")

	var load_voice_rec = true
	if load_voice_rec:
		voice_recognizer.initialize(
			lm.small_en, # model_path
			48000 # sample rate
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
	if recording_player.is_recording:
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

func _process(delta):
	if recording_player.is_recording and (recording_player.get_frames_available() > block_size):
		pass_audio_data()

func pass_audio_data():
	var sub_buffer = recording_player.get_buffer(block_size)
	voice_recognizer.accept_waveform(sub_buffer)
