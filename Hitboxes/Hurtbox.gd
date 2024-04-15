extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

@export var showHitEffect = true
@onready var timer: Timer = $InvincibilityTimer

var invincible = false

signal invincibility_start
signal invincibility_end

func createHitEffect():
	if !showHitEffect:
		return

	var effect = HitEffect.instantiate()
	var main = get_tree().current_scene

	effect.global_position = global_position - Vector2(0, 8)
	main.add_child(effect)

func startInvincibility(dur):
	invincible = true
	emit_signal("invincibility_start")
	timer.start(dur)

func _on_InvincibilityTimer_timeout():
	invincible = false
	emit_signal("invincibility_end")

func _on_invincibility_start():
	set_deferred("monitoring", false)

func _on_invincibility_end():
	monitoring = true
