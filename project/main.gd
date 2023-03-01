extends Node2D

onready var recording_player = $Recording_Player
onready var mouth_texture = $MouthTexture


var VoskRecognizerSource = load("res://bin/gdvosk.gdns")
var voice_recognizer = VoskRecognizerSource.new()
var audio_mix_rate: float = ProjectSettings.get_setting("audio/mix_rate")
var block_size: int = 1600

var buffer = StreamPeerBuffer.new()

var phoneme_labels: Array = ["SIL"]
var phoneme_timings: Array = [0.0]
var phoneme_starts: Array = [0.0]
var text_result: String = ""

var is_in_segment_transition := false

var lm: Dictionary = {
	small_en = "language_models/vosk-model-small-en-us-0.15"
}

func _ready():
	print("Starting Test!")

	voice_recognizer.initialize(
		lm.small_en, # model_path
		48000 # sample rate
		)
	var result_option := "phones"
	voice_recognizer.set_result_options("phones")
	voice_recognizer.set_verbose(false)

	assert($Test_HUD.connect("record_toggled", self, "_on_record_button_toggle") == 0)

	print("Model path: ", voice_recognizer.model_path)
	print("Sample rate: ", voice_recognizer.sample_rate)
	print("Buffer_size: ", voice_recognizer.buffer_size())
	print("Result option: ", result_option)

	print('End of Test Initialization\n')

func _on_record_button_toggle() -> void:
	if recording_player.is_recording:
		stop_recording()
	else:
		start_recording()

func start_recording() -> void:
	print("Microphone on")
	recording_player.start_recording()
	mouth_texture.reset_pointer()

func stop_recording() -> void:
	print("Microphone off")
	recording_player.stop_recording()

	var final_output = voice_recognizer.get_final()
	print(final_output)
	#print(JSON.parse(final_output).get_result()["text"])

func _physics_process(_delta):
	if recording_player.is_recording and (recording_player.get_frames_available() >= block_size):
		var accept_status: int = pass_audio_data()

		if accept_status == 0:
			text_result = JSON.parse(voice_recognizer.get_partial()).result.partial
		elif accept_status == 1:
			text_result = JSON.parse(voice_recognizer.get_final()).result.text
			is_in_segment_transition = true
		else:
			assert(false, "Something went wrong with voice_recognizer.accept_waveform().")

		var phone_output: Dictionary
		phone_output = JSON.parse(voice_recognizer.get_phone_partial()).result

		#if !is_in_segment_transition:
		phoneme_labels = phone_output.phone_labels
		phoneme_timings = phone_output.phone_end
		phoneme_starts = phone_output.phone_start

func pass_audio_data() -> int:
	var sub_buffer = recording_player.get_buffer(block_size)

	return voice_recognizer.accept_waveform(sub_buffer)

func _process(delta):
	mouth_texture.add_next_texture(phoneme_labels, phoneme_timings)
	mouth_texture.update_frame(delta)
