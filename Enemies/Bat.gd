extends CharacterBody2D

const KNOCKBACK_FORCE = 100

@onready var healthStats = $HealthStats

var knockback = Vector2.ZERO

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 225 * delta)
	velocity = knockback
	move_and_slide()

func _on_hurtbox_area_entered(area):
	knockback = get_knockback_direction(area.owner.position) * KNOCKBACK_FORCE
	healthStats.health = healthStats.health - area.damage

func get_knockback_direction(areaPosition):
	return (position - areaPosition).normalized()
	
func play_death_effect():
	var DeathEffect = load("res://Effects/EnemyDeathEffect.tscn")
	var effect = DeathEffect.instantiate()
	
	effect.global_position = global_position
	get_tree().current_scene.add_child(effect)

func _on_health_stats_no_health():
	play_death_effect()
	queue_free()
