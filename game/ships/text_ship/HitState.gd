extends AnimationState
class_name HitState
"""
State of text ship getting hit
Playes an animation and reduces label characters by number of them hit
"""

var hitChars: int = 1
var hitPosition: Vector2


func enterState(prevState: String):
	.enterState(prevState)
	entity.bodyCollider().disabled = true
	entity.hitCharacter(hitChars)
	print("HIT_POSITION: %s" % hitPosition)
	entity.emit_signal("shipHit", entity.currentText.length())
	
	
func exitState(nextState: String):
	.exitState(nextState)
	entity.bodyCollider().disabled = false
	
	
func scoreShipHitPoints():
	var extraLettersNum := max(hitChars - 1, 0)
	if extraLettersNum <= 0:
		return
	var perLetterBonusPoints: int = entity.perLetterBonusPoints * extraLettersNum
	var numPoints: int = perLetterBonusPoints
	
	entity.emit_signal("shipHitEarnedPoints", numPoints, entity.position)
