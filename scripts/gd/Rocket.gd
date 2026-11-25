@tool
class_name Rocket
extends Node2D

@export var AOE_RADIUS := 150.0
@export var AOE_DAMAGE := 50.0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_arc(Vector2.ZERO, AOE_RADIUS, 0.0, TAU, 64, Color(1.0, 0.5, 0.0, 0.8), 2.0)

func explode(world_position: Vector2) -> void:
	for enemy: Node in get_tree().get_nodes_in_group("enemy"):
		if enemy is BaseEnemy:
			var dist := world_position.distance_to((enemy as BaseEnemy).global_position)
			if dist <= AOE_RADIUS:
				(enemy as BaseEnemy).take_damage(AOE_DAMAGE)
	queue_free()
