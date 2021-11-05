extends DescendingState
class_name FastDescendingState
"""
Descending state subtype that creates illusion of faster descend
"""
const FloatingTextScn = preload("res://ships/text_ship/FloatingText.tscn")

export(float) var dropLetterCooldown: float = 3.5
onready var cooldownBar = get_node("../../CooldownBar")


func _ready():
	cooldownBar.cooldownTime = dropLetterCooldown



func _startNextPathSegment():
	var startPoint = descendPath[lastPathPointIdx]
	var traversalTime = ._startNextPathSegment()
	var endPoint = descendPath[lastPathPointIdx]
	
	var traverseDirection = sign(endPoint.x - startPoint.x)
	_checkShakeOffLetter()
	
	pathMover.interpolate_property(
		entity, "rotation_degrees", 
		0, traverseDirection * 360,  
		traversalTime, 
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	pathMover.start()
	
	

func _checkShakeOffLetter():
	if (entity.currentText.length() >= 2):
		if not cooldownBar.cooldownInProgress():
			cooldownBar.startCooldown()
			_shakeOffLetter()
				

func _shakeOffLetter():
	var firstLetter = entity.currentText.substr(0, 1)
	entity.currentText = entity.currentText.substr(1)
	var floatingText = FloatingTextScn.instance()
	floatingText.text = firstLetter
	floatingText.position = entity.position
	entity.emit_signal("shipDroppedLetter", floatingText)
