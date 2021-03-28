extends State
class_name IdlingState
"""
State for text ship to idle for fixed amount of time.
Typically between descend segments
"""
export(float) var idleTime: float = 1.6


var remainingIdleTime: float = 0.0
var idlingOver: bool = false

var idleInBubble: bool = false


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
	remainingIdleTime = idleTime
	idlingOver = false
	idleInBubble = randi() % 2 == 1
	if (idleInBubble):
		entity.bubble.anim.play("show")
	
	
func exitState(nextState: String):
	.exitState(nextState)
	if (idleInBubble):
		entity.bubble.anim.play("hide")
