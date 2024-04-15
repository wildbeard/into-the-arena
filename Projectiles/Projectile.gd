extends Area2D
# Ref: https://www.youtube.com/watch?v=um0zp7zBbt4

@export var speed: int = 300
@export var damage: int = 1
@export var offScreen: VisibleOnScreenEnabler2D = null
@export var maxRange: int = 0
@export var sticksToWalls: bool = false

var direction: Vector2 = Vector2.ZERO
var startingPos: Vector2 = Vector2.ZERO

func _ready():
	set_as_top_level(true)
	offScreen.connect("screen_exited", _on_visible_on_screen_enabler_2d_screen_exited)
	startingPos = global_position

func _process(delta):
	global_position += (Vector2.RIGHT * speed).rotated(rotation) * delta
	
	if maxRange > 0 && startingPos.distance_to(global_position) > maxRange:
		destroy()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	destroy()

func destroy() -> void:
	queue_free()

# Allow certain projectiles to stick to walls
func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if !sticksToWalls:
		return
	
	if body && body.is_in_group("walls"):
		speed = 0
		# Keep em around for a few seconds, then delete
		await get_tree().create_timer(3).timeout
		destroy()
