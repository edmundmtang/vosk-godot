extends AudioStreamPlayer

var capture_effect: AudioEffectCapture
var is_recording: bool = false

func _ready() -> void:
	capture_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index('Capture'), 0)

func start_recording() -> void:
	is_recording = true
	capture_effect.clear_buffer()

func stop_recording() -> void:
	is_recording = false

func get_discarded_frames() -> int:
	return capture_effect.get_discarded_frames()

func get_frames_available() -> int:
	return capture_effect.get_frames_available()

func get_pushed_frames() -> int:
	return capture_effect.get_pushed_frames()

func get_buffer(frames: int) -> PoolByteArray:
	return capture_effect.get_buffer_uint16(frames)
