extends AnimationState
class_name HitState
"""
State of text ship getting hit
Playes an animation and reduces label charactersby number of them hit
"""

var hitChars: int = 1


func enterState(prevState: String):
	.enterState(prevState)
	entity.hitCharacter(hitChars)
	entity.emit_signal("shipHit", entity.currentText.length())
	
	
func scoreShipHitPoints():
	var extraLettersNum := max(hitChars - 1, 0)
	if extraLettersNum <= 0:
		return
	var perLetterBonusPoints: int = entity.perLetterBonusPoints * extraLettersNum
	var numPoints: int = perLetterBonusPoints
	
	entity.emit_signal("shipHitEarnedPoints", numPoints, entity.position)
