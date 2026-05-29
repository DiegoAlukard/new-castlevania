extends Area2D
class_name StairTrigger

enum StairDirection { 
	UP_RIGHT, 
	UP_LEFT   
}

@export_category("Configurações da Escada")
@export var direction: StairDirection = StairDirection.UP_RIGHT
@export var is_top: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("start_climbing"):
		body.active_stair = self

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("start_climbing"):
		if body.active_stair == self:
			body.active_stair = null
