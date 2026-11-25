@tool
class_name LancerEnemy
extends BaseEnemy

var _attack_anim := "A_or"
var _flip_attack := false

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	match current_state:
		STATE.IDLE:
			_play_anim("Idle")
		STATE.MOVING:
			if _player != null:
				sprite.flip_h = _player.global_position.x < global_position.x
			_play_anim("Run")
		STATE.ATTACKING:
			sprite.flip_h = _flip_attack
			_play_anim(_attack_anim)
		STATE.DEAD:
			if sprite != null:
				sprite.stop()

func _perform_attack() -> void:
	if _player == null:
		return
	var dir := (_player.global_position - global_position).normalized()
	_flip_attack = dir.x < 0
	var d := dir
	if _flip_attack:
		d.x = -d.x
	var abs_x := absf(d.x)
	var abs_y := absf(d.y)
	if abs_y < abs_x * 0.4:
		_attack_anim = "A_or"
	elif abs_y > abs_x * 2.4:
		_attack_anim = "A_u" if d.y < 0.0 else "A_d"
	elif d.y < 0.0:
		_attack_anim = "A_ur"
	else:
		_attack_anim = "A_dr"
	_player.take_damage(ATTACK_DAMAGE)
