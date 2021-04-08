extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
const TextShipScn = preload("res://ships/text_ship/TextShip.tscn")

signal letterTyped(letter)

export(int, 5) var numShipsFrom: int = 1
export(int, 5) var numShipsTo: int = 5

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
	var preparedShips := _prepareTextShips()
	_addShipsToScene(preparedShips)
	
	
func _prepareTextShips() -> Array:
	var windowWidth: int = OS.window_size.x
	var numShips = numShipsFrom + randi() % (numShipsTo - numShipsFrom + 1) 
	var shipWords: Array = wordsProvider.takeWords(numShips)
	var shipsStartPos: Vector2 = Vector2(
		rand_range(100, 125),
		rand_range(50, 100)
	)
	var shipPositions: Array = positionsProdiver.generatePathSegments(shipsStartPos)
	
	_printFleetStats(numShips, shipPositions, shipWords)
	var preparedShips: Array = []
	for idx in range(numShips):
		var textShip := TextShipScn.instance()
		textShip.prepare(shipWords[idx], shipPositions[idx])
		preparedShips.append(textShip)
	return preparedShips
	
	
func _addShipsToScene(preparedShips: Array):
	for textShip in preparedShips:
		$TextShips.add_child(textShip)
		textShip.sprite.scale = Vector2.ZERO
		_registerShipHandlers(textShip)
	currentLiveShips = preparedShips.size()


func _registerShipHandlers(ship: TextShip) -> void:
	ship.connect("textShipCollidedShooter", self, "_finishStageCollided")
	ship.connect("textShipDestroyed", self, "_countDestroyedShip")
		

func _printFleetStats(numShips: int, shipPositions: Array, shipWords: Array):
	print("\n")
	print("Sending in fleet: %s ships" % numShips)
	var shipsStartX := []
	for vectorPos in shipPositions.slice(0, numShips - 1):
		shipsStartX.append(vectorPos.x)
	print(Utils.joinToString(shipsStartX, "%10.0d", " "))
	print(Utils.joinToString(shipWords, "%10s", " "))
	print("\n")
	
	
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
		if (is_instance_valid(shootableWithLetter) and shooter.roundChambered()):
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
		var preparedShips := _prepareTextShips()
		_addShipsToScene(preparedShips)
		

func _checkSpecialCodes(keyCode: String):
	if (keyCode == "Escape"):
		$BG/BGMusic.stream_paused = not $BG/BGMusic.stream_paused
	
	
