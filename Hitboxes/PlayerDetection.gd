extends Area2D

@onready var player = null

func playerIsInZone():
	return !!player

func _on_body_entered(body):
	if body.name == "Player":
		player = body

func _on_body_exited(body):
	if player && body.name == "Player":
		player = null
