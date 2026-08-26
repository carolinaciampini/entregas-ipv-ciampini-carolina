extends Sprite2D

@export var speed:float = 500

func _process(delta):

	var direction:int = 0

	if Input.is_action_pressed("mover_izq"):
		direction = -1
	elif Input.is_action_pressed("mover_der"):
		direction = 1

	position.x += direction * speed * delta
