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
onready var anim: AnimationPlayer = $AnimationPlayer


var path: Array = []
var lastPathPointIdx: int = 0
var remainingPointIdleTime: float = 0.0


func _ready():
	anim.play("appear")
	yield(anim, "animation_finished")
	path = ($PathGenerator as PathGenerator).generatePathSegments(position)
	lastPathPointIdx = 0
	remainingPointIdleTime = pathPointIdleSeconds
	

func hitCharacter() -> void:
	pathMover.stop_all()
	if (currentText.length() > 1):
		setCurrentText(currentText.substr(1))
		anim.play("hit")
		yield(anim, "animation_finished")
		pathMover.resume_all()
	else:
		setCurrentText("")
		anim.play("die")
	

func nextLetterIs(letter: String) -> bool:
	return currentText.begins_with(letter)
	
	
func _process(delta: float):
	#required not to have endless console Nil logs
	if (not is_instance_valid(pathMover)):
		return
	
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
	if (not anim.is_playing()):
		pathMover.start()




func setCurrentText(text: String) -> void:
	currentText = text.to_upper()
	if ($Sprite/Label):
		var label = $Sprite/Label
		label.text = currentText
		
		
func getCurrentText() -> String:
	if ($Sprite/Label):
		return $Sprite/Label.text
	else:
		return currentText


func _on_Area2D_area_entered(area: Area2D):
	if (anim.is_playing() and anim.current_animation == "die"):
		return
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		if (_projectileHitText(areaOwner)):
			hitCharacter()
		else:
			if (anim.is_playing() and anim.current_animation == "hit"):
				return
			anim.play("miss")
	
	
func _projectileHitText(projectile: Node2D) -> bool:
	var payload: String = projectile.label.text
	return nextLetterIs(payload)
