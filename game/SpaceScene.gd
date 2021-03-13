extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
const TextShipScn = preload("res://ships/TextShip.tscn")


signal letterTyped(letter)
signal letterMatchedShip(letter, ship)


export(String, FILE, "*.txt") var wordsCorpusFilePath: String


onready var textShipsList: Node2D = $TextShips
onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput


func _ready():
	connect("letterTyped", playerInput, "setTypedLetter")
	connect("letterMatchedShip", shooter, "faceAndShootTextShip")
	call_deferred("_prepareTextShips")
	
	
func _prepareTextShips() -> void:
	var fileText: String = _readFileText(wordsCorpusFilePath)
	var placementOriginX := 100
	for word in fileText.split("\n", false):
		var textShip = TextShipScn.instance()
		$TextShips.add_child(textShip)
		textShip.currentText = word
		textShip.position = Vector2(
			placementOriginX + rand_range(0, 100.0),
			rand_range(-50, 50)
		)
		placementOriginX = textShip.position.x + rand_range(100, 200)
		_registerShipsCollisionHandler()

	
	
func _readFileText(filePath: String) -> String:
	var file = File.new()
	file.open(filePath, File.READ)
	var content = file.get_as_text()
	file.close()
	return content



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
	
