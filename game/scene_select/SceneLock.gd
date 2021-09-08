tool
extends Panel
"""
Panel with a lock and points requirement drawn on it
"""
export(int) var pointsRequirementAmount: int = 500 setget _setReqAmount
export(String) var pointsRequirementFormat: String = "unlocks at [%04d] pts." setget _setReqFormat


onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	pass
	
	
func _setReqAmount(amount: int):
	pointsRequirementAmount = amount
	_updatePointsRequirement()
	
	
func _setReqFormat(format: String):
	pointsRequirementFormat = format
	_updatePointsRequirement()
	
	
func _updatePointsRequirement():
	$VBoxContainer/UnlockPointsRequirement.text = pointsRequirementFormat % pointsRequirementAmount
