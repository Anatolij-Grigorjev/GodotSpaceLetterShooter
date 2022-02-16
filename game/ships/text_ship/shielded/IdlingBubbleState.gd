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
		entity.bubble.show()
	
	
func exitState(nextState: String):
	.exitState(nextState)
	#burst state explicitly waits for shield to play burst animation
	#so we avoid hiding it
	if (entity.shipHasShield and nextState != "BubbleBurst"):
		entity.bubble.hide()
