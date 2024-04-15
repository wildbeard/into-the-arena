extends Node2D

@export var wanderRange: int = 0

@onready var startingPos: Vector2 = global_position
@onready var targetPos: Vector2 = global_position
@onready var timer: Timer = $Timer

var range: int = 0

func _ready():
	self.range = self.wanderRange

func _random_point_on_ring(outer_radius: float, inner_radius := 0.0):
	return Vector2.from_angle(randf() * TAU) * sqrt(randf_range(pow(1 - (outer_radius - inner_radius) / outer_radius, 2), 1)) * outer_radius

func _getWanderVec(range: int) -> Vector2:
	return _random_point_on_ring(range, range / 2)

func _updateTargetPos() -> void:
	var vec = self._getWanderVec(self.range)
	self.targetPos = self.startingPos + vec

func _on_timer_timeout():
	self._updateTargetPos()

func startWanderTimer(dur: float) -> void:
	self.timer.start(dur)

func getTimeRemaining() -> float:
	return self.timer.time_left

func getTargetPosition() -> Vector2:
	return self.targetPos

func getStartingPosition() -> Vector2:
	return self.startingPos

func setWanderRange(range: int) -> void:
	self.range = range
