extends IdlingState
class_name IdlingBubbleState
"""
Wait for next descend step while enclosed in bubble
"""
export(float) var idleTimeInBubble: float = 1.6


func processState(delta: float):
	if (entity.bubble.bubbleHit):
		return
	.processState(delta)

	
func enterState(prevState: String):
	.enterState(prevState)
	entity.bubble.anim.play("show")
	remainingIdleTime = idleTimeInBubble
	
	
func exitState(nextState: String):
	.exitState(nextState)
	entity.bubble.anim.play("hide")
