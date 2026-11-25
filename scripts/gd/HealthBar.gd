extends Node2D

const FILL_MAX := 1.88

@onready var fill: Sprite2D = $Fill

func _ready() -> void:
	#fill.centered = false
	fill.scale.x = FILL_MAX
	set_ratio(1.0)

func set_ratio(ratio: float) -> void:
	fill.scale.x = FILL_MAX * clampf(ratio, 0.0, 1.0)
