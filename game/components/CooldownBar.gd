extends ProgressBar
"""
Progress bar that ocunts down progress based on how much cooldown time is
left in timer
"""
signal cooldownFinished

export(float) var cooldownTime: float = 3.5
export(bool) var visibleInactive: bool = false

onready var timer = $Timer

func _ready():
	_refreshVisible()
	timer.wait_time = cooldownTime
	Utils.tryConnect(timer, "timeout", self, "_onCooldownFinished")
	
	
func startCooldown():
	visible = true
	timer.start()
	max_value = cooldownTime * 100
	min_value = 0.0
	value = max_value
	
	
func _process(delta):
	if not timer.is_stopped():
		value = timer.time_left * 100


func _onCooldownFinished():
	_refreshVisible()
	value = 0.0
	emit_signal("cooldownFinished")
	
	
func _refreshVisible():
	visible = visibleInactive
	
