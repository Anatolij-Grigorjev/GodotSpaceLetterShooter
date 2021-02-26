tool
extends Node2D
class_name TextShip
"""
Controller for ship with a piece of text in a label in a sprite
"""

export(String) var currentText: String = "test" setget setCurrentText, getCurrentText
export(float) var speed: float = 450
export(float) var pathPointIdleSeconds: float = 0.5


onready var sprite: Sprite = $Sprite
onready var label: Label = $Sprite/Label
onready var pathMover: Tween = $PathMover


var path: Array = []
var lastPathPointIdx: int = 0
var remainingPointIdleTime: float = 0.0


func _ready():
	$AnimationPlayer.play("appear")
	yield($AnimationPlayer, "animation_finished")
	path = $PathGenerator.generatePathSegments(position)
	lastPathPointIdx = 0
	remainingPointIdleTime = pathPointIdleSeconds
	
	
func _process(delta: float):
	#moving between path points
	if pathMover.is_active():
		return
	
	#path over
	if (lastPathPointIdx >= path.size() - 1):
		return
	
	#waiting at a point
	if remainingPointIdleTime > 0:
		remainingPointIdleTime -= delta
		return
	
	#wait at idle point over
	var startPoint = path[lastPathPointIdx]
	lastPathPointIdx += 1
	var endPoint = path[lastPathPointIdx]
	remainingPointIdleTime = pathPointIdleSeconds
	var moveTime = endPoint.distance_to(startPoint) / speed
	pathMover.interpolate_property(
		self, "position", 
		startPoint, endPoint,  
		moveTime, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	pathMover.start()


func setCurrentText(text: String) -> void:
	currentText = text
	if ($Sprite/Label):
		var label = $Sprite/Label
		label.text = text

func getCurrentText() -> String:
	if ($Sprite/Label):
		return $Sprite/Label.text
	else:
		return currentText
