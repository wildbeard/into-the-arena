extends Node

signal no_health
signal health_changed(value)

@export var max_health = 1:
	get:
		return max_health

	set(value):
		# Max can never be less than 1
		max_health = max(1, value)

@onready var health = max_health:
	get:
		return health
	
	set(value):
		# Current can never be below 0
		health = clamp(value, 0, max_health)
		health_changed.emit(value)
		
		if health <= 0:
			no_health.emit()
