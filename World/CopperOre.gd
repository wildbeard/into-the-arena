extends StaticBody2D

var available = true
var playerInArea = false
var sprites = {
	"unavailable": preload("res://World/Copper_Empty.png"),
	"available": preload("res://World/Copper.png")
}

func _ready():
	pass
	
func _process(delta):
	if playerInArea && Input.is_action_just_pressed("Gather"):
		setAvailable(false)
		startTimer()

func setAvailable(isAvail):
	available = isAvail
	
	if isAvail:
		$Sprite2D.texture = sprites.get("available")
	else:
		$Sprite2D.texture = sprites.get("unavailable")
	
func startTimer():
	$RespawnTimer.start()

func _on_respawn_timer_timeout():
	setAvailable(true)

func _on_gather_area_body_entered(body):
	playerInArea = body.name == "Player"

func _on_gather_area_body_exited(body):
	if playerInArea && body.name == "Player":
		playerInArea = false
