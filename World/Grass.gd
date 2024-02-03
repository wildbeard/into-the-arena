extends Node2D

func play_death_effect():
	var DeathEffect = load("res://Effects/Grass/GrassDeathEffect.tscn")
	var effect = DeathEffect.instantiate()
	
	effect.global_position = global_position
	get_tree().current_scene.add_child(effect)

func _on_hurtbox_area_entered(area):
	play_death_effect()
	queue_free()
