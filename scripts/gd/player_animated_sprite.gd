extends AnimatedSprite2D
@onready var parent: Player = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_playing():
		return
	
	match(parent.current_state):
		parent.STATE.IDLE:
			play("default")
		parent.STATE.MOVING:
			play("walk")
		parent.STATE.DASHING:
			play("dash")
		parent.STATE.DEAD:
			play("death")
