extends Node2D

@onready var cannon_tip: Node2D = $CannonTip

@export var projectile_scene: PackedScene

var projectile_container: Node


func process_input() -> void:
	look_at(get_global_mouse_position())


func fire() -> void:
	if projectile_container == null:
		return
	var proj_instance: Node2D = projectile_scene.instantiate()
	proj_instance.initialize(
		projectile_container,
		cannon_tip.global_position,
		global_position.direction_to(cannon_tip.global_position)
	)
