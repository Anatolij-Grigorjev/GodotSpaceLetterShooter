extends Timer
"""
Kind of timer that is not paused with rest of tree and is used to
pause it for short durations (like a free frame effect)
"""

export(float) var defaultFreezeTime = 0.05



func _ready():
	one_shot = true
	wait_time = defaultFreezeTime
	connect("timeout", self, "_endFreezeFrame")
	
	
func startFreeze(duration: float = defaultFreezeTime):
	wait_time = duration
	start()
	get_tree().paused = true
	

func _endFreezeFrame():
	get_tree().paused = false
