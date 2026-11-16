class_name Player
extends CharacterBody2D

@export var DASH_INPUTS_NEEDED := 2
@export var DASH_MAGNITUDE := 1000
@export var SPEED = 300.0

const JUMP_VELOCITY = -400.0

enum STATE {
	IDLE,
	MOVING,
	DASHING,
	DEAD
}

var current_state : STATE = STATE.IDLE
var isLookingRight : bool = true
var _seen_dash_inputs := 0

func _process(delta: float) -> void:
	print(current_state)

func _physics_process(delta: float) -> void:
	
	# Track Dash Inputs
	if Input.is_action_just_pressed("Dash"):
		_seen_dash_inputs += 1
	
	if _seen_dash_inputs >= DASH_INPUTS_NEEDED:
		var last_motion := get_last_motion()
		
		if last_motion != Vector2.ZERO:
			velocity += last_motion * DASH_MAGNITUDE

		_seen_dash_inputs = 0
		current_state = STATE.DASHING
		
		move_and_slide()
		return

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
