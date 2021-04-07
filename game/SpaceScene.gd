extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
const TextShipScn = preload("res://ships/text_ship/TextShip.tscn")

signal letterTyped(letter)

export(int, 5) var numShips: int = 1

onready var wordsProvider: WordsProvider = $WordsProvider
onready var positionsProdiver: PathGenerator = $PathGenerator
onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput

var currentLiveShips := 0


func _ready():
	G.currentScene = self
	connect("letterTyped", playerInput, "addTypedLetter")
	connect("letterTyped", shooter, "chamberLetter")
	shooter.connect("shotFired", playerInput, "clearText")
	_prepareTextShips()
	
	
func _prepareTextShips() -> void:
	var windowWidth: int = OS.window_size.x
	var shipWords: Array = wordsProvider.takeWords(numShips)
	print("Sending in fleet: %s" % [shipWords])
	var shipsStartPos: Vector2 = Vector2(
		rand_range(100, 125),
		rand_range(50, 100)
	)
	var shipPositions: Array = positionsProdiver.generatePathSegments(shipsStartPos)
	for idx in range(numShips):
		var textShip := TextShipScn.instance()
		$TextShips.add_child(textShip)
		textShip.prepare(shipWords[idx], shipPositions[idx])
	_registerShipsHandlers()
	currentLiveShips = numShips



func _registerShipsHandlers() -> void:
	for node in $TextShips.get_children():
		var ship: TextShip = node as TextShip
		ship.connect("textShipCollidedShooter", self, "_finishStageCollided")
		ship.connect("textShipDestroyed", self, "_countDestroyedShip")
		


func _process(delta: float):
	pass
	
func _input(event: InputEvent) -> void:
	if (not event is InputEventKey):
		return
	var keyEvent: InputEventKey = event as InputEventKey
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = OS.get_scancode_string(keyEvent.scancode)
	
	_checkSpecialCodes(keyCharCode)
	
	var firePressed: bool = false
	if (keyCharCode == "Space"):
		firePressed = true
	elif (keyCharCode.length() > 1):
		return
	else:
		emit_signal("letterTyped", keyCharCode)

	var shootableWithLetter: Node2D = _findShootableWithNextText(shooter.chamber)
	if (is_instance_valid(shootableWithLetter)):
		shooter.faceShootable(shootableWithLetter)
	if (firePressed):
		if (is_instance_valid(shootableWithLetter)):
			shooter.fireChambered(shootableWithLetter)
		else:
			shooter.missFire()
	

func _isKeyJustPressed(keyEvent: InputEventKey) -> bool:
	return not keyEvent.echo and keyEvent.pressed
	

func _findShootableWithNextText(text: String) -> Node2D:
	for node in get_tree().get_nodes_in_group("shootable"):
		var shootable: Node2D = node as Node2D
		if (shootable.nextTextIs(text)):
			return shootable
	return null
	
	
func _finishStageCollided():
	get_tree().quit()
	
	
func _countDestroyedShip():
	currentLiveShips -= 1
	if (currentLiveShips <= 0):
		yield(get_tree(), "idle_frame")
		_prepareTextShips()
		

func _checkSpecialCodes(keyCode: String):
	if (keyCode == "Escape"):
		$BG/BGMusic.stream_paused = not $BG/BGMusic.stream_paused
	
	
