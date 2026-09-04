extends Node


func _ready():
	$Player.set_projectile_container(self)
	get_tree().call_group("turrets", "set_values", $Player, self)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
