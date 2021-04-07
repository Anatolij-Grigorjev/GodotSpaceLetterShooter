extends AnimationState
class_name DieState
"""
State for text ship to dissapear because 
last label character was hit
"""

func processState(delta: float):
	if (animationFinished):
		entity.emit_signal("textShipDestroyed")
		entity.queue_free()
	
	
func enterState(prevState: String):
	.enterState(prevState)
	entity.currentText = ""
