extends Node2D

signal record_toggled()

# Called when the node enters the scene tree for the first time.
func _ready():
	assert($Button.connect("pressed", self, "_toggle_record") == 0)

func _toggle_record() -> void:
	emit_signal("record_toggled")
