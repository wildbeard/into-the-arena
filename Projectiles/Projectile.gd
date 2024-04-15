extends Area2D
# Ref: https://www.youtube.com/watch?v=um0zp7zBbt4

@export var speed: int = 300
@export var damage: int = 1
@export var offScreen: VisibleOnScreenEnabler2D = null

var direction: Vector2 = Vector2.ZERO

func _ready():
	set_as_top_level(true)
	offScreen.connect("screen_exited", _on_visible_on_screen_enabler_2d_screen_exited)

func _process(delta):
	var d = (Vector2.RIGHT * speed).rotated(rotation) * delta
	global_position += d

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	destroy()

func destroy() -> void:
	queue_free()
