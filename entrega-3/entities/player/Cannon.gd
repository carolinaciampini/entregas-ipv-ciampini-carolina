extends Sprite2D

@onready var cannon_tip: Node2D = $CannonTip

@export var projectile_scene: PackedScene

var projectile_container: Node

func fire() -> void:
	var proj_instance: Node2D = projectile_scene.instantiate()
	proj_instance.initialize(
		projectile_container,
		cannon_tip.global_position,
		global_position.direction_to(cannon_tip.global_position)
	)
