extends State
class_name IdlingState
"""
State for text ship to idle for fixed amount of time.
Typically between descend segments
"""
export(float) var idleTimeInBubble: float = 1.6
export(float) var idleTimeBare: float = 0.7


var remainingIdleTime: float = 0.0
var idlingOver: bool = false

var idleInBubble: bool = false

func _ready():
	randomize()


func processState(delta: float):
	if (idlingOver):
		return
		
	if (entity.bubble.bubbleHit):
		return
		
	remainingIdleTime -= delta
	if (remainingIdleTime < 0.0):
		idlingOver = true
		return
	
	
func enterState(prevState: String):
	.enterState(prevState)
	idlingOver = false
	idleInBubble = (randi() % 100) < entity.bubbleChancePrc
	if (idleInBubble):
		entity.bubble.anim.play("show")
		remainingIdleTime = idleTimeInBubble
	else:
		remainingIdleTime = idleTimeBare
	
	
func exitState(nextState: String):
	.exitState(nextState)
	if (idleInBubble):
		entity.bubble.anim.play("hide")
