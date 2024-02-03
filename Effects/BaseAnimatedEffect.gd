extends AnimatedSprite2D

@export var animation_name = "Animate"

func _ready():
	connect("animation_finished", on_animation_finished)
	frame = 0
	play(animation_name)
	
func on_animation_finished():
	queue_free()
