class_name Player
extends CharacterBody2D

@export var DASH_INPUTS_NEEDED := 2
@export var DASH_SPEED := 1000
@export var SPEED = 300.0

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite

const JUMP_VELOCITY = -400.0
const DASH_ANIMATION_LENGTH_IN_SECONDS = 0.5
const DASH_FRAME_COUNT = 11
const DASH_MOVE_START_FRAME = 4  # zero-indexed, first "empty" frame
const DASH_MOVE_END_FRAME = 6    # zero-indexed, last "empty" frame (inclusive)

enum STATE {
	IDLE,
	MOVING,
	DASHING,
	FIRING,
	DEAD
}

var current_state : STATE = STATE.IDLE
var bazooka_state : STATE = STATE.IDLE
var isLookingRight : bool = true
var _seen_dash_inputs := 0
var _dash_dir := Vector2.ZERO
var _dash_time_left := 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Fire"):
		bazooka_state = STATE.FIRING
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Dash"):
		_seen_dash_inputs += 1

	# Start a dash
	if current_state != STATE.DASHING and _seen_dash_inputs >= DASH_INPUTS_NEEDED:
		_seen_dash_inputs = 0
		var dir := velocity.normalized()  # or your input direction vector
		if dir != Vector2.ZERO:
			_dash_dir = dir
			_dash_time_left = DASH_ANIMATION_LENGTH_IN_SECONDS
			current_state = STATE.DASHING

	if current_state == STATE.DASHING:
		var elapsed := DASH_ANIMATION_LENGTH_IN_SECONDS - _dash_time_left
		var frame_duration := DASH_ANIMATION_LENGTH_IN_SECONDS / DASH_FRAME_COUNT
		var move_start := DASH_MOVE_START_FRAME * frame_duration
		var move_end := (DASH_MOVE_END_FRAME + 1) * frame_duration
		if elapsed >= move_start and elapsed < move_end:
			velocity = _dash_dir * DASH_SPEED
		else:
			velocity = Vector2.ZERO
		_dash_time_left -= delta
		if _dash_time_left <= 0.0:
			current_state = STATE.IDLE
		
	else:
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var hor_dir := Input.get_axis("Left", "Right")
		var ver_dir := Input.get_axis("Up", "Down")
		
		if hor_dir:
			velocity.x = hor_dir * SPEED
			isLookingRight = true if hor_dir > 0 else false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if ver_dir:
			velocity.y = ver_dir * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		
		if hor_dir or ver_dir:
			current_state = STATE.MOVING
		else: 
			current_state = STATE.IDLE
		
	move_and_slide()
