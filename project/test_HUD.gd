extends Node2D

signal record_toggled()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.connect("pressed", self, "_toggle_record")

func _toggle_record() -> void:
	emit_signal("record_toggled")
