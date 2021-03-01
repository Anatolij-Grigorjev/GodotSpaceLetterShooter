extends Control
"""
Panel to display latest player input 
while shoot-typing
"""

onready var label: Label = $Panel/Label

func _ready():
	pass # Replace with function body.


func setTypedLetter(letter: String) -> void:
	label.text = letter
