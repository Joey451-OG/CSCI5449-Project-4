extends AnimatedSprite2D
@onready var parent: Player = $".."

var _orbit_radius: float
var _shadow: AnimatedSprite2D

func _ready() -> void:
	_orbit_radius = position.length()

func _process(delta: float) -> void:
	var to_mouse := (get_global_mouse_position() - parent.global_position).normalized()
	position = to_mouse * _orbit_radius
	rotation = to_mouse.angle()

	match(parent.bazooka_state):
		parent.STATE.IDLE:
			play("idle")
		parent.STATE.FIRING:
			play("fire")
