extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

@export var showHitEffect = true

func _on_area_entered(area):
	if !showHitEffect:
		return

	var effect = HitEffect.instantiate()
	var main = get_tree().current_scene

	effect.global_position = global_position - Vector2(0, 8)
	main.add_child(effect)
