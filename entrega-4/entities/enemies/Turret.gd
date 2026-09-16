extends StaticBody2D
class_name Turret

@onready var fire_position: Node2D = $FirePosition
@onready var fire_timer: Timer = $FireTimer
@onready var raycast: RayCast2D = $RayCast2D
@onready var body_animation: AnimatedSprite2D = $Body

@export var projectile_scene: PackedScene

var projectile_container: Node
var target: Node2D
var dead: bool = false


func _ready() -> void:
	add_to_group("turrets")
	fire_timer.timeout.connect(fire_at_player)
	body_animation.animation_finished.connect(_on_animation_finished)
	body_animation.play("idle")
	set_physics_process(false)


func initialize(turret_pos: Vector2, projectile_container: Node) -> void:
	global_position = turret_pos
	self.projectile_container = projectile_container


func fire_at_player() -> void:
	if dead or target == null or not is_instance_valid(target):
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
	fire_timer.start()


func _physics_process(_delta: float) -> void:
	if dead or target == null:
		return

	raycast.target_position = raycast.to_local(target.global_position)
	raycast.force_raycast_update()
	if raycast.is_colliding() and raycast.get_collider() == target:
		if fire_timer.is_stopped():
			fire_timer.start()
	elif not fire_timer.is_stopped():
		fire_timer.stop()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if not dead and target == null and body.is_in_group("player"):
		target = body
		set_physics_process(true)
		fire_timer.start()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		fire_timer.stop()
		set_physics_process(false)


func notify_hit() -> void:
	if dead:
		return
	dead = true
	set_physics_process(false)
	fire_timer.stop()
	collision_layer = 0
	collision_mask = 0
	$DetectionArea.monitoring = false
	$DetectionArea.monitorable = false
	body_animation.play("die")


func _on_animation_finished() -> void:
	if body_animation.animation == &"die":
		queue_free()
