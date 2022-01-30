extends IdlingState
class_name IdlingBubbleState
"""
Like regular idling, but enclosed in shield bubble
"""

func processState(delta: float):
	if (entity.bubble.bubbleHit):
		return
	.processState(delta)

	
func enterState(prevState: String):
	.enterState(prevState)
	if (entity.shipHasShield):
		entity.bubble.anim.play("show")
	
	
func exitState(nextState: String):
	.exitState(nextState)
	if (entity.shipHasShield):
		entity.bubble.anim.play("hide")
