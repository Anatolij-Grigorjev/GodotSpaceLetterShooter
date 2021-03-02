extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal letterTyped(letter)
signal letterMatchedShip(letter, ship)


onready var textShipsList: Node2D = $TextShips
onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput


func _ready():
	#TODO: configure new ships
	connect("letterTyped", playerInput, "setTypedLetter")
	connect("letterMatchedShip", shooter, "faceAndShootTextShip")

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
	emit_signal("letterTyped", keyCharCode)
	var textShipWithLetter: TextShip = _findShipWithNextTextLetter(keyCharCode)
	if (is_instance_valid(textShipWithLetter)):
		emit_signal("letterMatchedShip", keyCharCode, textShipWithLetter)
		textShipWithLetter.hitCharacter()
	

func _isKeyJustPressed(keyEvent: InputEventKey) -> bool:
	return not keyEvent.echo and keyEvent.pressed
	

func _findShipWithNextTextLetter(letter: String) -> TextShip:
	for node in textShipsList.get_children():
		var textShip: TextShip = node as TextShip
		if (textShip.nextLetterIs(letter)):
			return textShip
	return null
