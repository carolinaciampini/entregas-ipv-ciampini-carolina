extends CharacterBody2D
class_name Player

@onready var cannon: Node = $Cannon

@export var ACCELERATION: float = 20.0
@export var H_SPEED_LIMIT: float = 600.0
@export var FRICTION_WEIGHT: float = 0.1
@export var JUMP_SPEED: float = -10
@export var GRAVITY: float = 2
@export var PUSH_FORCE: float = 10.0

var projectile_container: Node


func initialize(projectile_container):
	self.projectile_container = projectile_container
	cannon.projectile_container = projectile_container


func _get_input():
	# Cannon rotation
	var mouse_position: Vector2 = get_global_mouse_position()
	cannon.look_at(mouse_position)
	
	# Cannon fire
	if Input.is_action_just_pressed("fire_cannon"):
		if projectile_container == null:
			projectile_container = get_parent()
			cannon.projectile_container = projectile_container
		cannon.fire()
	
	# Player movement
	var h_movement_direction: int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	
	if h_movement_direction != 0:
		velocity.x = clamp(velocity.x + (h_movement_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT) if abs(velocity.x) > 1.0 else 0.0
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED


func _physics_process(delta):
	_get_input()
	velocity.y += GRAVITY 
	# Basado en https://youtu.be/SJuScDavstM
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var collision_normal: Vector2 = collision.get_normal()
			var velocity_alignment: float = float(collision_normal.dot(-velocity.normalized()) > 0.0) #clamp(
				#collision_normal.dot(-velocity.normalized()) * 3.0,
				#0.0,
				#1.0
			#)
			collision.get_collider().apply_central_impulse(
				-collision_normal.slerp(-velocity.normalized(), 0.5) * PUSH_FORCE * velocity_alignment
			)
	
	move_and_slide()


func notify_hit() -> void:
	queue_free()
