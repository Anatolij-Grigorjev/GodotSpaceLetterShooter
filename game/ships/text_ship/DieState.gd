extends AnimationState
class_name DieState
"""
State for text ship to dissapear because 
last label character was hit
"""

var entityText := ""
var finalShotLettersNum: int = 0

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
	var lettersBonusPoints: int = entity.perLetterBonusPoints * max(finalShotLettersNum - 1, 0)
	var numPoints: int = entity.baseKillPoints + lettersBonusPoints
	
	entity.emit_signal("shipKillEarnedPoints", numPoints, entity.position)
	
