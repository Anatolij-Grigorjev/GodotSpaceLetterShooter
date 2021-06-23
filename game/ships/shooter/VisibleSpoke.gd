extends Sprite
"""
Show spoke at random rotation and time it out
"""

export(Vector2) var allowedRotationRange = Vector2(70.0, 280.0)
export(float) var spokeTimeout = 0.25


onready var timer = $Timer


func _ready():
	timer.wait_time = spokeTimeout
	Utils.tryConnect(timer, "timeout", self, "_onTimeout")
	

func showSpoke():
	visible = true
	#autoresets if started
	timer.start()
	rotation_degrees = allowedRotationRange.x + randf() * (allowedRotationRange.y - allowedRotationRange.x)
	flip_h = randi() % 2 == 0
	flip_v = randi() % 2 == 0


func _onTimeout():
	visible = false
	queue_free()
