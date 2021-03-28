extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
const TextShipScn = preload("res://ships/TextShip.tscn")

signal letterTyped(letter)

export(int, 5) var numShips: int = 1

onready var wordsProvider: WordsProvider = $WordsProvider
onready var positionsProdiver: PathGenerator = $PathGenerator
onready var textShipsList: Node2D = $TextShips
onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput


func _ready():
	connect("letterTyped", playerInput, "addTypedLetter")
	connect("letterTyped", shooter, "chamberLetter")
	shooter.connect("shotFired", playerInput, "clearText")
	_prepareTextShips()
	
	
func _prepareTextShips() -> void:
	var windowWidth: int = OS.window_size.x
	var shipWords: Array = wordsProvider.takeWords(numShips)
	var shipsStartPos: Vector2 = Vector2(
		rand_range(100, 125),
		rand_range(50, 100)
	)
	var shipPositions: Array = positionsProdiver.generatePathSegments(shipsStartPos)
	for idx in range(numShips):
		var textShip := TextShipScn.instance()
		$TextShips.add_child(textShip)
		textShip.currentText = shipWords[idx]
		textShip.position = shipPositions[idx]
	_registerShipsCollisionHandler()



func _registerShipsCollisionHandler() -> void:
	for node in $TextShips.get_children():
		var ship: TextShip = node as TextShip
		ship.connect("textShipCollidedShooter", self, "_finishStageCollided")


func _process(delta: float):
	pass
	
func _input(event: InputEvent) -> void:
	if (not event is InputEventKey):
		return
	var keyEvent: InputEventKey = event as InputEventKey
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = OS.get_scancode_string(keyEvent.scancode)
	
	var firePressed: bool = false
	if (keyCharCode == "Space"):
		firePressed = true
	elif (keyCharCode.length() > 1):
		return
	else:
		emit_signal("letterTyped", keyCharCode)

	var textShipWithLetter: TextShip = _findShipWithNextText(shooter.chamber)
	if (is_instance_valid(textShipWithLetter)):
		shooter.faceShip(textShipWithLetter)
	if (firePressed):
		if (is_instance_valid(textShipWithLetter)):
			shooter.fireChambered(textShipWithLetter)
		else:
			shooter.missFire()
	

func _isKeyJustPressed(keyEvent: InputEventKey) -> bool:
	return not keyEvent.echo and keyEvent.pressed
	

func _findShipWithNextText(text: String) -> TextShip:
	for node in textShipsList.get_children():
		var textShip: TextShip = node as TextShip
		if (textShip.nextTextIs(text)):
			return textShip
	return null
	
	
func _finishStageCollided():
	get_tree().quit()
	
