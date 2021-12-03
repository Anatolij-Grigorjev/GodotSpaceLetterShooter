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
	entity.bodyCollider().disabled = true
	_hideVisibleProgressBars()
	entity.emit_signal("shipHit", 0)
	entityText = str(entity.currentText)
	entity.currentText = ""
	
	
func scoreShipKillPoints():
	var extraLettersNum := max(finalShotLettersNum - 1, 0)
	var perLetterBonusPoints: int = entity.perLetterBonusPoints * extraLettersNum
	var allLetterBonus: float = perLetterBonusPoints * (1.0 + extraLettersNum / 10.0)
	var numPoints: int = entity.baseKillPoints + allLetterBonus
	
	entity.emit_signal("shipHitEarnedPoints", numPoints, entity.position)
	
	
func _hideVisibleProgressBars():
	var entityProgressBars = Utils.getNodeChildrenOfType(entity, ProgressBar)
	for progressBar in entityProgressBars:
		if progressBar.visible:
			progressBar.visible = false
