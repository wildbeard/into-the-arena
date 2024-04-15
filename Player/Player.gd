extends CharacterBody2D

const ACCELERATION = 625 # 375
const FRICTION = 10000
const MAX_SPEED = 95
const SPRINT_MODIFIER = 0.15
const INVINCIBILITY_TIMER = 0.5

enum MoveState {
	MOVE,
	ROLL,
}

enum AttackState {
	NONE,
	ATTACK,
}

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var hurtbox = $Hurtbox
var moveState = MoveState.MOVE
var attackState = AttackState.NONE
var rollVector = Vector2.DOWN
var isAttacking: bool = false
var stats = PlayerStats
var arrowScene = preload("res://Projectiles/Arrow.tscn")
var fireballScene = preload("res://Projectiles/Fireball.tscn")

func _ready():
	self.stats.max_health = 4
	self.stats.connect('no_health', queue_free)
	animationTree.active = true

func _physics_process(delta):
	# Two state machines allows the user to move + attack
	# but doesn't allow the user to attack + roll or change
	# direction and roll.
	match moveState:
		MoveState.MOVE:
			move_state(delta)
		MoveState.ROLL:
			roll_state(delta)
	
	if isAttacking:
		attack_state(delta)
		
	if Input.is_action_just_pressed("Attack"):
		isAttacking = true
		attackState = AttackState.ATTACK

	if Input.is_action_just_pressed("left_click"):
		var fireball = fireballScene.instantiate()
		var mousePos = get_global_mouse_position()
		$Marker2D.look_at(mousePos)
		fireball.global_position = $Marker2D.global_position
		fireball.rotation = $Marker2D.rotation
		add_child(fireball)
	
func move_state(delta):
	var input = Vector2()
	input.x = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	input.y = int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))

	if input != Vector2.ZERO:
		rollVector = input.normalized()
		set_blend_positions(input)
		var speed = input.normalized() * MAX_SPEED
		
		if Input.is_key_pressed(KEY_SHIFT):
			speed += speed * SPRINT_MODIFIER

		animationState.travel("Run")
		velocity = velocity.move_toward(speed, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("Roll"):
		moveState = MoveState.ROLL

	if Input.is_action_just_pressed("Attack"):
		# attackState = AttackState.ATTACK
		pass

func set_blend_positions(input):
	animationTree.set("parameters/Idle/blend_position", input)
	animationTree.set("parameters/Run/blend_position", input)
	animationTree.set("parameters/Attack/blend_position", input)
	animationTree.set("parameters/Roll/blend_position", input)

func roll_state(delta):
	velocity = velocity.move_toward(rollVector * MAX_SPEED * 1.5, ACCELERATION * delta)
	animationState.travel("Roll")
	move()
	# Simple i-frame
	hurtbox.startInvincibility(0.25)

func attack_state(delta):
	animationState.travel("Attack")
	await animationPlayer.get_current_animation_length()
	
func move():
	move_and_slide()

func attack_animation_started():
	pass

func attack_animation_complete():
	isAttacking = false
	attackState = AttackState.NONE
	print("animation complete")
	
func roll_animation_complete():
	moveState = MoveState.MOVE

func _on_hurtbox_area_entered(area):
	hurtbox.startInvincibility(INVINCIBILITY_TIMER)
	hurtbox.createHitEffect()
	self.stats.health -= 1
