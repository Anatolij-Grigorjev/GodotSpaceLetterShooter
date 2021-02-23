tool
extends Node2D
class_name TextShip
"""
Controller for ship with a piece of text in a label in a sprite
"""

export(String) var currentText: String = "test" setget setCurrentText, getCurrentText

onready var sprite: Sprite = $Sprite
onready var label: Label = $Sprite/Label



func _ready():
	$AnimationPlayer.play("appear")
	yield($AnimationPlayer, "animation_finished")
	
	

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
