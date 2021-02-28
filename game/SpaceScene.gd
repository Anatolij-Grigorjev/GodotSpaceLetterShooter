extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""

onready var textShipsList: Node2D = $TextShips
onready var shooter = $ShooterShip


func _ready():
	#prepare ships
	pass # Replace with function body.



func _process(delta: float):
	pass
	
func _input(event: InputEvent) -> void:
	if (not event is InputEventKey):
		return
	var keyEvent: InputEventKey = event as InputEventKey
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = OS.get_scancode_string(keyEvent.scancode)
	if (keyCharCode.length() > 1):
		return
	$CanvasLayer/PlayerInput/Panel/Label.text += keyCharCode
	var textShipWithLetter: TextShip = _findShipWithNextTextLetter(keyCharCode)
	if (is_instance_valid(textShipWithLetter)):
		textShipWithLetter.hitCharacter()
	

func _isKeyJustPressed(keyEvent: InputEventKey) -> bool:
	return not keyEvent.echo and keyEvent.pressed
	

func _findShipWithNextTextLetter(letter: String) -> TextShip:
	for node in textShipsList.get_children():
		var textShip: TextShip = node as TextShip
		if (textShip.nextLetterIs(letter)):
			return textShip
	return null
