extends VoskSpeechRecognizer

var model_path = "speech_recognizer/language_models/vosk-model-small-en-us-0.15"
var sample_rate: float = ProjectSettings.get_setting("audio/driver/mix_rate")
var is_running : bool = false

func _ready() -> void:
    start()

func start() -> void:
    initialize(model_path, sample_rate)
    set_words_option(true)
    set_phones_option(true)
    set_timings_option(true)
    is_running = true
