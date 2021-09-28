extends DescendingState
class_name FastDescendingState
"""
Descending state subtype that creates illusion of faster descend
"""
export(int) var numSwitchesLoseLetter = 2
var lastTraverseDirection: float = 1.0

var elapsedDirectionSwitches = 0



func _startNextPathSegment():
	var startPoint = descendPath[lastPathPointIdx]
	var traversalTime = ._startNextPathSegment()
	var endPoint = descendPath[lastPathPointIdx]
	
	var traverseDirection = sign(endPoint.x - startPoint.x)
	_checkShakeOffLetter(traverseDirection)
	lastTraverseDirection = traverseDirection
	
	pathMover.interpolate_property(
		entity, "rotation_degrees", 
		0, traverseDirection * 360,  
		traversalTime, 
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	pathMover.start()
	
	

func _checkShakeOffLetter(newTraverseDirection: float):
	if (entity.currentText.length() >= 2):
		if lastTraverseDirection != newTraverseDirection:
			elapsedDirectionSwitches += 1
			if (elapsedDirectionSwitches == numSwitchesLoseLetter):
				entity.currentText = entity.currentText.substr(1)
				elapsedDirectionSwitches = 0
