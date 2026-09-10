extends Node2D

@export var turret_scene: PackedScene
@export var number_of_turrets: int = 3
@export var spawn_area_extents: Vector2 = Vector2(180, 80)

var initialized: bool = false


func _ready() -> void:
	call_deferred("initialize")


func initialize(target_player = null) -> void:
	if initialized:
		return
	initialized = true
	
	for i in number_of_turrets:
		var turret_instance: Node2D = turret_scene.instantiate()
		
		# Posición aleatoria en el mundo alrededor de la posición del spawner
		var turret_pos: Vector2 = Vector2(
			randf_range(global_position.x - spawn_area_extents.x, global_position.x + spawn_area_extents.x),
			randf_range(global_position.y - spawn_area_extents.y, global_position.y + spawn_area_extents.y)
		)
		
		get_parent().add_child(turret_instance)
		turret_instance.initialize(turret_pos, get_parent())
