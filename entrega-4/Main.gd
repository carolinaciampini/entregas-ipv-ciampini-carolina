extends Node

@onready var player: Node2D = $Player

func _ready() -> void:
	randomize()
	player.initialize(self)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
