extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
const TextShipScn = preload("res://ships/TextShip.tscn")

signal letterTyped(letter)
signal letterMatchedShip(letter, ship)

export(int) var numShips: int = 5

onready var wordsProvider: WordsProvider = $WordsProvider
onready var positionsProdiver: PathGenerator = $PathGenerator
onready var textShipsList: Node2D = $TextShips
onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput


func _ready():
	connect("letterTyped", playerInput, "setTypedLetter")
	connect("letterMatchedShip", shooter, "faceAndShootTextShip")
	_prepareTextShips()
	
	
func _prepareTextShips() -> void:
	var windowWidth: int = OS.window_size.x
	var shipWords: Array = wordsProvider.takeWords(numShips)
	var shipsStartPos: Vector2 = Vector2(
		rand_range(100, 125),
		rand_range(25, 75)
	)
	var shipPositions: Array = positionsProdiver.generatePathSegments(shipsStartPos)
	for idx in range(0, numShips):
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
	if (keyCharCode.length() > 1):
		return
	emit_signal("letterTyped", keyCharCode)
	var textShipWithLetter: TextShip = _findShipWithNextTextLetter(keyCharCode)
	if (is_instance_valid(textShipWithLetter)):
		emit_signal("letterMatchedShip", keyCharCode, textShipWithLetter)
	

func _isKeyJustPressed(keyEvent: InputEventKey) -> bool:
	return not keyEvent.echo and keyEvent.pressed
	

func _findShipWithNextTextLetter(letter: String) -> TextShip:
	for node in textShipsList.get_children():
		var textShip: TextShip = node as TextShip
		if (textShip.nextLetterIs(letter)):
			return textShip
	return null
	
	
func _finishStageCollided():
	get_tree().quit()
	
