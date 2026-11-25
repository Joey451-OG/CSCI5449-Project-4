@tool
class_name MonkEnemy
extends BaseEnemy

@export var HEAL_AMOUNT := 20.0
@export var HEAL_RANGE := 220.0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	if _player != null and current_state == STATE.MOVING:
		sprite.flip_h = _player.global_position.x < global_position.x
	match current_state:
		STATE.IDLE:
			_play_anim("Idle")
		STATE.MOVING:
			_play_anim("Run")
		STATE.ATTACKING:
			_play_anim("Heal")
		STATE.DEAD:
			if sprite != null:
				sprite.stop()

func _perform_attack() -> void:
	for enemy: Node in get_tree().get_nodes_in_group("enemy"):
		if enemy == self:
			continue
		if enemy is BaseEnemy and global_position.distance_to(enemy.global_position) <= HEAL_RANGE:
			(enemy as BaseEnemy).heal(HEAL_AMOUNT)
	if _player != null and global_position.distance_to(_player.global_position) <= HEAL_RANGE:
		_player.heal(HEAL_AMOUNT)
