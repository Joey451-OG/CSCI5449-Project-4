@tool
class_name BaseEnemy
extends CharacterBody2D

@export var SPEED := 80.0
@export var MAX_HEALTH := 100.0
@export var DETECT_RANGE := 400.0
@export var ATTACK_RANGE := 60.0
@export var ATTACK_DAMAGE := 10.0
@export var ATTACK_COOLDOWN := 1.5

enum STATE { IDLE, MOVING, ATTACKING, DEAD }

var current_state: STATE = STATE.IDLE
var health: float
var _attack_timer := 0.0
var _player: Player = null
var _health_bar: Node2D = null

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	_health_bar = get_node_or_null("HealthBar") as Node2D
	if Engine.is_editor_hint():
		queue_redraw()
		return
	health = MAX_HEALTH
	add_to_group("enemy")
	_update_health_bar()

func _update_health_bar() -> void:
	if _health_bar != null and _health_bar.has_method("set_ratio"):
		_health_bar.set_ratio(health / MAX_HEALTH)

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_arc(Vector2.ZERO, ATTACK_RANGE, 0.0, TAU, 64, Color.RED, 2.0)
	draw_arc(Vector2.ZERO, DETECT_RANGE, 0.0, TAU, 64, Color.GREEN, 2.0)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if current_state == STATE.DEAD:
		return
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_refresh_player_ref()
	_update_state()
	_apply_movement()
	move_and_slide()

func _refresh_player_ref() -> void:
	if is_instance_valid(_player):
		return
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player = players[0] as Player

func _update_state() -> void:
	if _player == null:
		current_state = STATE.IDLE
		return
	var dist := global_position.distance_to(_player.global_position)
	if dist <= ATTACK_RANGE:
		if _attack_timer <= 0.0:
			_attack_timer = ATTACK_COOLDOWN
			current_state = STATE.ATTACKING
			_perform_attack()
	elif dist <= DETECT_RANGE:
		current_state = STATE.MOVING
	else:
		current_state = STATE.IDLE

func _apply_movement() -> void:
	match current_state:
		STATE.MOVING:
			if _player != null:
				velocity = (_player.global_position - global_position).normalized() * SPEED
		_:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)

func _perform_attack() -> void:
	pass

func _play_anim(anim_name: String) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(anim_name):
		return
	if sprite.animation != StringName(anim_name) or not sprite.is_playing():
		sprite.play(anim_name)

func take_damage(amount: float) -> void:
	if current_state == STATE.DEAD:
		return
	health = maxf(health - amount, 0.0)
	_update_health_bar()
	if health <= 0.0:
		_die()

func heal(amount: float) -> void:
	if current_state == STATE.DEAD:
		return
	health = minf(health + amount, MAX_HEALTH)
	_update_health_bar()

func _die() -> void:
	current_state = STATE.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)
	await get_tree().create_timer(1.0).timeout
	queue_free()
