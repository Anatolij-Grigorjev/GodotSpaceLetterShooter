extends Control
"""
Panel to display latest player input 
while shoot-typing
"""

onready var label: Label = $Panel/Label

func _ready():
	clearText()


func addTypedLetter(letter: String) -> void:
	label.text += letter
	

func clearText():
	label.text = ""
