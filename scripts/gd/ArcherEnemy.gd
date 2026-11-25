@tool
class_name ArcherEnemy
extends BaseEnemy

@export var PREFERRED_DISTANCE := 300.0
@export var FLEE_DISTANCE := 150.0

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
			_play_anim("Fire")
		STATE.DEAD:
			if sprite != null:
				sprite.stop()

func _apply_movement() -> void:
	if _player == null or current_state == STATE.IDLE or current_state == STATE.DEAD:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		return
	var dist := global_position.distance_to(_player.global_position)
	if dist < FLEE_DISTANCE:
		velocity = (global_position - _player.global_position).normalized() * SPEED
	elif dist > PREFERRED_DISTANCE + 50.0:
		velocity = (_player.global_position - global_position).normalized() * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

func _perform_attack() -> void:
	if _player != null:
		_player.take_damage(ATTACK_DAMAGE)
