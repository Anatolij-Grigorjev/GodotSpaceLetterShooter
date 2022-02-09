extends AnimatedSprite
"""
Show spoke at random rotation and time it out
"""

export(Vector2) var allowedRotationFromTo = Vector2(70.0, 280.0)
export(float) var spokeTimeout = 0.25


onready var tween = $Tween

var allowedRotationRange: NumRange



func _ready():
	allowedRotationRange = NumRange.new(allowedRotationFromTo.x, allowedRotationFromTo.y)
	tween.interpolate_property(
		self, "modulate", 
		null, Color.transparent, 
		0.25, Tween.TRANS_EXPO, Tween.EASE_OUT, 
		spokeTimeout
	)
	tween.connect("tween_all_completed", self, "_spokeGone")
	

func showSpoke():
	visible = true
	#autoresets if started
	tween.start()
	rotation_degrees = allowedRotationRange.random()
	flip_h = randi() % 2 == 0


func _spokeGone():
	visible = false
	queue_free()
