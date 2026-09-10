extends Sprite2D

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var area: Area2D = $Area2D

@export var VELOCITY: float = 800.0
@export var LIFETIME: float = 15.0
@export var is_enemy: bool = false

var direction: Vector2 = Vector2.ZERO
var is_queued_for_deletion: bool = false


func initialize(container: Node, spawn_position: Vector2, direction: Vector2) -> void:
	container.add_child(self)
	self.direction = direction
	global_position = spawn_position
	
	if lifetime_timer:
		lifetime_timer.wait_time = LIFETIME
		if not lifetime_timer.timeout.is_connected(_on_lifetime_timer_timeout):
			lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)
		lifetime_timer.start()


func _ready() -> void:
	if area:
		if not area.body_entered.is_connected(_on_body_entered):
			area.body_entered.connect(_on_body_entered)
		if not area.area_entered.is_connected(_on_area_entered):
			area.area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += direction * VELOCITY * delta


func _on_body_entered(body: Node2D) -> void:
	# Si impacta contra el jugador
	if body is Player or body.name == "Player":
		if is_enemy:
			if body.has_method("notify_hit"):
				body.notify_hit()
			else:
				body.queue_free()
			_remove()
		return
	
	# Si impacta contra una torreta (en caso de que sea o tenga un body)
	if body is Turret or body.name.begins_with("Turret"):
		if not is_enemy:
			if body.has_method("notify_hit"):
				body.notify_hit()
			else:
				body.queue_free()
			_remove()
		return
	
	# Cualquier otro cuerpo del entorno (piso, cubos, rampas, etc.)
	# Desaparece de inmediato sin aplicar fuerzas ni derribar objetos
	_remove()


func _on_area_entered(other_area: Area2D) -> void:
	# Ignorar el rango de detección visual de la torreta
	if other_area.name == "DetecctionArea":
		return
	
	var parent_node = other_area.get_parent()
	if parent_node != null:
		# Proyectil del jugador impactando a la torreta
		if not is_enemy and (parent_node is Turret or parent_node.name.begins_with("Turret") or parent_node.has_method("notify_hit")):
			if parent_node.has_method("notify_hit"):
				parent_node.notify_hit()
			else:
				parent_node.queue_free()
			_remove()
			return
		
		# Proyectil enemigo impactando al jugador
		elif is_enemy and (parent_node is Player or parent_node.name == "Player"):
			if parent_node.has_method("notify_hit"):
				parent_node.notify_hit()
			else:
				parent_node.queue_free()
			_remove()
			return
	
	# Choque entre dos proyectiles
	if other_area.get_parent() is Sprite2D and other_area.get_parent().has_method("_remove"):
		_remove()


func _on_lifetime_timer_timeout() -> void:
	_remove()


func _remove() -> void:
	if is_queued_for_deletion:
		return
	is_queued_for_deletion = true
	queue_free()
