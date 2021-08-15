extends AnimationState
class_name DieState
"""
State for text ship to dissapear because 
last label character was hit
"""

var entityText := ""

func processState(delta: float):
	if (animationFinished):
		entity.emit_signal("textShipDestroyed", entityText)
		entity.queue_free()
	
	
func enterState(prevState: String):
	.enterState(prevState)
	entity.emit_signal("shipHit", 0)
	entityText = str(entity.currentText)
	entity.currentText = ""
	
	
func scoreShipKillPoints():
	
	var numPoints: int = 300
	entity.emit_signal("shipKillEarnedPoints", numPoints, entity.position)
	
