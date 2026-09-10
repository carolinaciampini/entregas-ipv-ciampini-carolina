extends Sprite2D
class_name Turret

@onready var fire_position: Node2D = $FirePosition
@onready var fire_timer: Timer = $FireTimer

@export var projectile_scene: PackedScene

var projectile_container: Node
var target: Node2D


func _ready():
	if not fire_timer.timeout.is_connected(fire_at_player):
		fire_timer.timeout.connect(fire_at_player)


func initialize(turret_pos: Vector2, projectile_container: Node) -> void:
	global_position = turret_pos
	self.projectile_container = projectile_container


func fire_at_player() -> void:
	if target == null or not is_instance_valid(target):
		fire_timer.stop()
		return
	
	if projectile_container == null:
		projectile_container = get_parent()
	
	# Verificar si hay una pared o colisión entre la torreta y el jugador
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(fire_position.global_position, target.global_position)
	query.collision_mask = 3 # Capa 1 (paredes, pisos, cubos) y Capa 2 (jugador)
	var result = space_state.intersect_ray(query)
	
	# Solo disparar si la línea de visión llega directamente al jugador
	if result.is_empty() or result.collider != target:
		return
	
	var proj_instance = projectile_scene.instantiate()
	proj_instance.initialize(
		projectile_container,
		fire_position.global_position,
		fire_position.global_position.direction_to(target.global_position)
	)


func _on_detecction_area_body_entered(body: Node2D): 
	if target == null and body is Player:
		target = body
		fire_timer.start()


func _on_detecction_area_body_exited(body: Node2D):
	if body == target:
		target = null
		fire_timer.stop()


func notify_hit() -> void:
	queue_free()
