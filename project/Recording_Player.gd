extends AudioStreamPlayer

var record_effect: AudioEffectRecord
var capture_effect: AudioEffectCapture
var audio_buffer:= StreamPeerBuffer.new()

var recording_timer: float = 0.0
var recording_delay: float = 0.1

func _ready() -> void:
	record_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index('Record'), 0)
	capture_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index('Record'), 1)


func start_recording() -> void:
	record_effect.set_recording_active(true)
	recording_timer = 0

func stop_recording() -> void:
	record_effect.set_recording_active(false)
	audio_buffer.clear()

func _process(delta) -> void:
	if record_effect.is_recording_active():
		print(capture_effect.get_buffer(128))
		recording_timer += delta
		if recording_timer > recording_delay:
			recording_timer -= recording_delay
			recording_to_buffer()

func recording_to_buffer() -> void:
	"""
	record_effect.set_recording_active(false)
	audio_buffer.put_data(record_effect.get_recording().data)
	record_effect.set_recording_active(true)
	"""

