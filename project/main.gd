extends Node2D

@onready var recording_player = $Recording_Player
@onready var mouth_texture = $MouthTexture
@onready var fps_label = $FPSLabel

var VoskRecognizerSource = load("res://bin/gdvosk.gdns")
var voice_recognizer = VoskRecognizerSource.new()
var audio_mix_rate: float = ProjectSettings.get_setting("audio/driver/mix_rate")
var physics_fps: float = ProjectSettings.get_setting("physics/common/physics_fps")
var force_fps: float = ProjectSettings.get_setting("debug/settings/fps/force_fps")

var result_option := "phones"
var verbose_option := false

var buffer = StreamPeerBuffer.new()
var timer : float = 0.0
var force_delta: float = 1.0/30
var animation_delay : float = 0.5
var block_size : int = 1600
var accept_status := 01

var frame_counter : int = 0
var delta_total : float = 0

var phoneme_labels : Array = ["SIL"]
var phoneme_timings : Array = [0.0]
var phoneme_starts : Array = [0.0]
var text_result : String = ""

var is_in_between_sequences := false

var lm: Dictionary = {
    small_en = "language_models/vosk-model-small-en-us-0.15"
}

func _ready():
    print("Starting Test!")
    initialize_parameters()
    mouth_texture.initialization(animation_delay, force_delta)
    initialize_voice_recognizer()

    assert($Test_HUD.connect("record_toggled",Callable(self,"_on_record_button_toggle")) == 0)
    assert(mouth_texture.connect("end_of_sequence",Callable(self,"align_timers")) == 0)

    print("Model path: ", voice_recognizer.model_path)
    print("Sample rate: ", voice_recognizer.sample_rate)
    print("Buffer_size: ", voice_recognizer.buffer_size())
    print("Effective block size: ", block_size * 2)
    print("Result option: ", result_option)
    print('End of Test Initialization\n')

func initialize_parameters() -> void:
    self.block_size = audio_mix_rate / physics_fps * 2
    self.force_delta = 1 / force_fps

func initialize_voice_recognizer() -> void:
    voice_recognizer.initialize(
        lm.small_en, # model_path
        audio_mix_rate # sample rate
        )
    voice_recognizer.set_result_options(result_option)
    voice_recognizer.set_verbose(verbose_option)

func _on_record_button_toggle() -> void:
    if recording_player.is_recording:
        stop_recording()
    else:
        start_recording()

func start_recording() -> void:
    print("Microphone on")
    recording_player.start_recording()
    full_reset_timer()
    align_timers()

func stop_recording() -> void:
    print("Microphone off")
    recording_player.stop_recording()

func align_timers() -> void:
    mouth_texture.timer = timer
    is_in_between_sequences = false

func full_reset_timer() -> void:
    timer = 0 - animation_delay - force_delta

func _physics_process(delta):
    if recording_player.is_recording and (recording_player.get_frames_available() >= block_size):
        accept_status = pass_audio_data()
    timer += delta

func pass_audio_data() -> int:
    var sub_buffer = recording_player.get_buffer(block_size)
    return voice_recognizer.accept_waveform(sub_buffer)

func _process(delta):
    update_fps_label(delta)
    if recording_player.is_recording:
        if accept_status == 0:
            var test_json_conv = JSON.new()
            print(voice_recognizer.get_partial())
            #test_json_conv.parse(voice_recognizer.get_partial()).result.partial
            text_result = test_json_conv.get_data()
        elif accept_status == 1:
            var test_json_conv = JSON.new()
            #test_json_conv.parse(voice_recognizer.get_final()).result.text
            text_result = test_json_conv.get_data()
            full_reset_timer()
            is_in_between_sequences = true
    """
        if !is_in_between_sequences:
            var phone_output: Dictionary
            var test_json_conv = JSON.new()
            test_json_conv.parse(voice_recognizer.get_phone_partial()).result
            phone_output = test_json_conv.get_data()
            phoneme_labels = phone_output.phone_labels
            phoneme_timings = phone_output.phone_end
    """
    # Texture2D updates
    mouth_texture.update_texture(phoneme_labels, phoneme_timings, delta)

func update_fps_label(delta) -> void:
    frame_counter += 1
    delta_total += delta
    if frame_counter == 10:
        fps_label.text = str(frame_counter/delta_total).pad_decimals(1)
        frame_counter = 0
        delta_total = 0
