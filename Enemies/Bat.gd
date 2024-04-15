extends CharacterBody2D

enum EnemyState {
	IDLE,
	WANDER,
	CHASE
}
const KNOCKBACK_FORCE = 100

@export var acceleration = 500
@export var maxSpeed = 50
@export var wanderRange: int = 32

@onready var healthStats = $HealthStats
@onready var playerDetection = $PlayerDetection
@onready var hurtbox = $Hurtbox
@onready var softCollider = $SoftCollision
@onready var wanderCtrl: Node2D = $WanderController

var knockback = Vector2.ZERO
var currentState = EnemyState.IDLE
var prevState: int = EnemyState.IDLE
var lastPos = Vector2.ZERO

func _ready():
	self.wanderCtrl.setWanderRange(self.wanderRange)
	updateWander()

func _physics_process(delta):
	if knockback > Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, 225 * delta)
		velocity = knockback
		move_and_slide()
	
	match currentState:
		EnemyState.IDLE:
			var pos = wanderCtrl.getStartingPosition() if prevState == EnemyState.CHASE else Vector2.ZERO
			velocity = velocity.move_toward(pos, 225 * delta)
			seekPlayer()
			
			if wanderCtrl.getTimeRemaining() == 0:
				updateWander()

		EnemyState.CHASE:
			prevState = EnemyState.CHASE
			var player = playerDetection.player
			
			if player:
				_accelerateToPosition(player.global_position, delta)
			else:
				currentState = EnemyState.IDLE

		EnemyState.WANDER:
			# Look for the player even while wandering
			seekPlayer()
			var pos = wanderCtrl.getTargetPosition()
			_accelerateToPosition(pos, delta)

			if global_position.distance_to(pos) <= maxSpeed * delta || wanderCtrl.getTimeRemaining() == 0:
				updateWander()

	if softCollider.isColliding():
		# 1200 feels way too high
		velocity += softCollider.getPushVector() * delta * 1200

	move_and_slide()

func _accelerateToPosition(pos: Vector2, delta: float) -> void:
	var dir = global_position.direction_to(pos).normalized()
	velocity = velocity.move_toward(dir * maxSpeed, acceleration * delta)
	$AnimatedSprite2D.flip_h = velocity.x < 0

func updateWander():
	prevState = currentState
	currentState = getNewState([EnemyState.IDLE, EnemyState.WANDER])
	wanderCtrl.startWanderTimer(randf_range(1, 3))

func seekPlayer():
	if playerDetection.playerIsInZone():
		currentState = EnemyState.CHASE

func getNewState(states: Array):
	states.shuffle()
	return states.pick_random()

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
