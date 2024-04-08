extends CharacterBody2D

enum EnemyState {
	IDLE,
	WANDER,
	CHASE
}
const KNOCKBACK_FORCE = 100

@export var acceleration = 500
@export var maxSpeed = 50
@onready var healthStats = $HealthStats
@onready var playerDetection = $PlayerDetection
@onready var hurtbox = $Hurtbox

var knockback = Vector2.ZERO
var currentState = EnemyState.IDLE

func _physics_process(delta):
	if knockback > Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, 225 * delta)
		velocity = knockback
		move_and_slide()
	
	match currentState:
		EnemyState.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 225 * delta)
			seekPlayer()
		EnemyState.CHASE:
			var player = playerDetection.player
			
			if player:
				var playerDir = position.direction_to(player.global_position).normalized()
				velocity = velocity.move_toward(playerDir * maxSpeed, acceleration * delta)
			else:
				currentState = EnemyState.IDLE

		EnemyState.WANDER:
			pass

	$AnimatedSprite2D.flip_h = velocity.x < 0
	move_and_slide()

func seekPlayer():
	if playerDetection.playerIsInZone():
		currentState = EnemyState.CHASE

func _on_hurtbox_area_entered(area):
	knockback = get_knockback_direction(area.owner.position) * KNOCKBACK_FORCE
	healthStats.health = healthStats.health - area.damage
	hurtbox.createHitEffect()

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
