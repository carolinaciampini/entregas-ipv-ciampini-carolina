extends Node


func _ready() -> void:
	# Variamos la semilla para que los spawns no repitan siempre el mismo patrón.
	randomize()


## Reinicia la escena completa usando la acción "reset" configurada en el proyecto.
func _input(event: InputEvent) -> void:
	if event.is_action(&"reset"):
		get_tree().reload_current_scene()
