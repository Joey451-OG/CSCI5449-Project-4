@tool
class_name PawnEnemy
extends BaseEnemy

@export var ATTACK_FRAME := 2

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
			_play_anim("Attack")
			_perform_attack()
		STATE.DEAD:
			if sprite != null:
				sprite.stop()

func _perform_attack() -> void:
	if _player != null and sprite.frame == ATTACK_FRAME:
		_player.take_damage(ATTACK_DAMAGE)
