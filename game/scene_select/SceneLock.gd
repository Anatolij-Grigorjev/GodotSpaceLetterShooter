tool
extends Panel
"""
Panel with a lock and scene unlock requirement drawn on it
"""
export(String) var unlockRequirementsFormat: String = "" setget _setReqFormat


onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	pass
	
	
func playUnlockSequence():
	anim.play("flash")
	yield(anim, "animation_finished")
	anim.play("unlock")
	yield(anim, "animation_finished")
	
	
func _setReqFormat(format: String):
	unlockRequirementsFormat = format
