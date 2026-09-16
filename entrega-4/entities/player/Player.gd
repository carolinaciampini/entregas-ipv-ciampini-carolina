extends CharacterBody2D
class_name Player

@onready var cannon: Node = $Cannon
@onready var body_animations: AnimationPlayer = $BodyAnimations
@onready var body_pivot: Node2D = $BodyPivot

@export var ACCELERATION: float = 1800.0
@export var H_SPEED_LIMIT: float = 360.0
@export var FRICTION_WEIGHT: float = 1400.0
@export var JUMP_SPEED: float = -420.0
@export var GRAVITY: float = 1050.0
@export var PUSH_FORCE: float = 80.0

var projectile_container: Node
var horizontal_input: float = 0.0
var jump_requested: bool = false
var dead: bool = false


func _ready() -> void:
	add_to_group("player")
	body_animations.animation_finished.connect(_on_animation_finished)
	_play_animation("idle")


func initialize(container: Node = null) -> void:
	if container == null:
		container = get_parent()
	projectile_container = container
	cannon.projectile_container = container


func _get_input() -> void:
	if dead:
		return

	horizontal_input = Input.get_axis("move_left", "move_right")
	jump_requested = Input.is_action_just_pressed("jump")

	if Input.is_action_just_pressed("fire_cannon"):
		cannon.fire()

	cannon.process_input()


func _physics_process(delta: float) -> void:
	_get_input()

	if dead:
		return

	var desired_speed := horizontal_input * H_SPEED_LIMIT
	if horizontal_input != 0.0:
		velocity.x = move_toward(velocity.x, desired_speed, ACCELERATION * delta)
		body_pivot.scale.x = -1.0 if horizontal_input < 0.0 else 1.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION_WEIGHT * delta)

	if jump_requested and is_on_floor():
		velocity.y = JUMP_SPEED

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = min(velocity.y, 0.0)

	if not is_on_floor():
		_play_animation("jump")
	elif horizontal_input != 0.0:
		_play_animation("walk")
	else:
		_play_animation("idle")

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
	if dead:
		return
	dead = true
	collision_layer = 0
	cannon.hide()
	_play_animation("die")


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"die":
		hide()
		set_physics_process(false)


func _play_animation(animation_name: String) -> void:
	if body_animations.has_animation(animation_name) and body_animations.current_animation != StringName(animation_name):
		body_animations.play(animation_name)
