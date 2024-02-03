extends CharacterBody2D

const ACCELERATION = 625 # 375
const FRICTION = 10000
const MAX_SPEED = 95
const SPRINT_MODIFIER = 0.15

enum PlayerState {
	ATTACK,
	MOVE,
	ROLL,
}

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
var state = PlayerState.MOVE
var rollVector = Vector2.DOWN

func _ready():
	animationTree.active = true

func _physics_process(delta):
	match state:
		PlayerState.MOVE:
			move_state(delta)
		PlayerState.ATTACK:
			attack_state(delta)
		PlayerState.ROLL:
			roll_state(delta)
	
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
		state = PlayerState.ROLL

	if Input.is_action_just_pressed("Attack"):
		state = PlayerState.ATTACK

func set_blend_positions(input):
	animationTree.set("parameters/Idle/blend_position", input)
	animationTree.set("parameters/Run/blend_position", input)
	animationTree.set("parameters/Attack/blend_position", input)
	animationTree.set("parameters/Roll/blend_position", input)

func roll_state(delta):
	velocity = velocity.move_toward(rollVector * MAX_SPEED * 1.5, ACCELERATION * delta)
	animationState.travel("Roll")
	move()

func attack_state(delta):
	animationState.travel("Attack")
	
func move():
	move_and_slide()
	
func attack_animation_complete():
	state = PlayerState.MOVE
	
func roll_animation_complete():
	state = PlayerState.MOVE
