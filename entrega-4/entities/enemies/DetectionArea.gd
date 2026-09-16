extends Area2D

@onready var detection_marker: Sprite2D = $GreenCircle


func _ready() -> void:
	detection_marker.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_enemy_detection_area"):
		detection_marker.visible = not detection_marker.visible
