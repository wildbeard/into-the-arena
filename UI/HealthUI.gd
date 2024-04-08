extends Control

@export var player: CharacterBody2D
@onready var heartsEmpty: TextureRect = $HeartEmpty
@onready var hearts: TextureRect = $Heart

var maxHp = 0;
var hp = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	self.player.stats.connect("health_changed", _on_health_changed)
	self.maxHp = player.stats.max_health
	self.hp = player.stats.health
	
	self.hearts.size.x = self.hp * 15
	self.heartsEmpty.size.x = self.maxHp * 15

func _on_health_changed(value):
	self.hp = value
	self.updateUI()

func updateUI():
	if self.hp == 0:
		self.hearts.visible = false
	else:
		self.hearts.size.x = self.hp * 15
