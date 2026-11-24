extends AnimatedSprite2D
@onready var parent: Player = $".."
@onready var sh_south: Sprite2D = $"../Shadows/South"
@onready var sh_north: Sprite2D = $"../Shadows/North"
@onready var sh_east: Sprite2D = $"../Shadows/East"
@onready var sh_west: Sprite2D = $"../Shadows/West"

@export var rocket_tip_offset: float = 60.0
@export var rocket_arc_height: float = 80.0
@export var rocket_duration: float = 0.5

const ROCKET_TEXTURE := preload("res://sprites/Bazooka_Rocket.png")

var _orbit_radius: float
var _prev_firing := false
var _rocket: Sprite2D = null
var _rocket_start := Vector2.ZERO
var _rocket_end := Vector2.ZERO
var _rocket_t := 1.0
var _target_shadow: Sprite2D = null
var _target_shadow_global_pos := Vector2.ZERO


func _ready() -> void:
	_orbit_radius = position.length()
	sh_north.visible = false
	sh_south.visible = false
	sh_east.visible = false
	sh_west.visible = false


func _process(delta: float) -> void:
	var to_mouse := (get_global_mouse_position() - parent.global_position).normalized()
	position = to_mouse * _orbit_radius
	rotation = to_mouse.angle()

	if rad_to_deg(rotation) < -90 or rad_to_deg(rotation) > 90:
		flip_v = true
	else:
		flip_v = false

	var shadows := [sh_north, sh_south, sh_east, sh_west]
	var closest: Sprite2D = null
	var min_diff := TAU
	for sh: Sprite2D in shadows:
		var diff := absf(angle_difference(rotation, sh.position.angle()))
		if diff < min_diff:
			min_diff = diff
			closest = sh
	for sh: Sprite2D in shadows:
		sh.visible = sh == closest

	var is_firing := parent.bazooka_state == parent.STATE.FIRING
	if is_firing and not _prev_firing:
		_target_shadow = closest
		_launch_rocket(_target_shadow)
	_prev_firing = is_firing

	if _rocket and _rocket_t < 1.0:
		_target_shadow.visible = true
		_target_shadow.global_position = _target_shadow_global_pos
		_rocket_t = minf(_rocket_t + delta / rocket_duration, 1.0)
		_rocket.position = parent.to_local(_bezier(_rocket_start, _rocket_end, _rocket_t))
		_rocket.rotation = _bezier_tangent(_rocket_start, _rocket_end, _rocket_t).angle()
		if _rocket_t >= 1.0:
			_target_shadow.visible = false
			_rocket.queue_free()
			_rocket = null

	match(parent.bazooka_state):
		parent.STATE.IDLE:
			play("idle")
		parent.STATE.FIRING:
			play("fire")


func _launch_rocket(active_shadow: Sprite2D) -> void:
	if active_shadow == null:
		return
	if _rocket:
		_rocket.queue_free()
	var scaled_tip_offset := rocket_tip_offset * scale.x
	_rocket_start = global_position + Vector2(scaled_tip_offset, 0.0).rotated(rotation)
	_rocket_end = active_shadow.global_position
	_target_shadow_global_pos = active_shadow.global_position
	_rocket_t = 0.0
	_rocket = Sprite2D.new()
	_rocket.texture = ROCKET_TEXTURE
	_rocket.scale = Vector2(2, 2)
	_rocket.z_index = 5
	_rocket.position = _rocket_start
	parent.add_child(_rocket)


func _bezier(start: Vector2, end: Vector2, t: float) -> Vector2:
	var control := (start + end) / 2.0 + Vector2(0.0, -rocket_arc_height)
	var mt := 1.0 - t
	return mt * mt * start + 2.0 * mt * t * control + t * t * end


func _bezier_tangent(start: Vector2, end: Vector2, t: float) -> Vector2:
	var control := (start + end) / 2.0 + Vector2(0.0, -rocket_arc_height)
	return 2.0 * (1.0 - t) * (control - start) + 2.0 * t * (end - control)


func _on_animation_finished() -> void:
	parent.bazooka_state = parent.STATE.IDLE
