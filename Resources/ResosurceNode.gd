extends StaticBody2D

enum ResourceNodeType {
	ORE,
	TREE,
}
enum ResourceType {
	COPPER,
	IRON
}

@export var sprites = {
	"available": "",
	"unavailable": "",
}
@export var resourceNodeType = ResourceNodeType.ORE
@export var resourceType = ResourceType.COPPER
@export var startsAvailable = false
@export var respawnTimer = 25

var available = true
var playerInArea = false
var availSprite = null
var unavailSprite = null

func _ready():
	if !sprites.has_all(["available", "unavailable"]):
		print("No sprites!", sprites)
		return
	
	availSprite = load(sprites.get("available"))
	unavailSprite = load(sprites.get("unavailable"))
	setAvailable(startsAvailable)
	$RespawnTimer.wait_time = respawnTimer

func _process(delta):
	if playerInArea && Input.is_action_just_pressed("Gather"):
		setAvailable(false)
		$RespawnTimer.start()

func setAvailable(isAvail):
	available = isAvail

	if isAvail:
		$Sprite.texture = availSprite
	else:
		$Sprite.texture = unavailSprite

func _on_gather_area_body_entered(body):
	if body.name == "Player":
		playerInArea = true

func _on_gather_area_body_exited(body):
	if playerInArea && body.name == "Player":
		playerInArea = false

func _on_respawn_timer_timeout():
	setAvailable(true)
