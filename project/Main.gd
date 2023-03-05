extends Node2D

@onready var recording_player := $RecordingPlayer
@onready var speech_recognizer := $VoskSpeechRecognizer

var audio_mix_rate: float = ProjectSettings.get_setting("audio/driver/mix_rate")
var physics_fps: float = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
var force_fps: float = ProjectSettings.get_setting("debug/settings/fps/force_fps")

var buffer = StreamPeerBuffer.new()
var timer : float = 0.0
var block_size : int = 1600
var force_delta: float = 1.0/30
var accept_waveform_status := 1

var json = JSON.new()
var text_result : String = ""
var phoneme_labels : Array
var phoneme_timings : Array



func _ready():
    print("Starting Test!")

    $TestHUD.record_toggled.connect(
        func () -> void:
            _on_record_button_toggle()
    )

func initialize_parameters() -> void:
    self.block_size = audio_mix_rate / physics_fps * 2
    self.force_delta = 1 / force_fps

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

func _physics_process(delta):
    if recording_player.is_recording and (recording_player.get_frames_available() >= block_size):
        accept_waveform_status = pass_audio_data()
    timer += delta

func pass_audio_data() -> int:
    var sub_buffer = recording_player.get_buffer(block_size)
    return speech_recognizer.accept_waveform(sub_buffer)

func _process(_delta):
    if recording_player.is_recording and timer >= 0.25:
        if accept_waveform_status == 0:
            json.parse(speech_recognizer.get_partial())
            text_result = json.data.text
        elif accept_waveform_status == 1:
            json.parse(speech_recognizer.get_final())
            text_result = json.data.text
        timer = 0

        json.parse(speech_recognizer.get_phone_partial())
        phoneme_labels = json.data.phone_label
        phoneme_timings = json.data.phone_end

        print("Text: ", text_result)
        print("Phoneme Labels: ", phoneme_labels)
        print("Phoneme End Times: ", phoneme_timings)
