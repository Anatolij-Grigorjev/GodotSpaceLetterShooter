extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal sceneCleared(sceneName)

const TextShipScn = preload("res://ships/text_ship/TextShip.tscn")

signal letterTyped(letter)

export(String) var sceneName: String = "Scene 1 - 1"

export(int, 99) var numShipsScene: int = 10
export(int, 5) var numShipsWaveFrom: int = 1
export(int, 5) var numShipsWaveTo: int = 5


onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput
onready var shipsFactory = $TextShipFactory


var currentLiveShips := 0
var remainingSceneShips := 0

var shipsBuilderThread: Thread


func _ready():
	G.currentScene = self
	remainingSceneShips = numShipsScene
	shipsBuilderThread = Thread.new()
	connect("letterTyped", playerInput, "addTypedLetter")
	connect("letterTyped", shooter, "chamberLetter")
	shooter.connect("shotFired", playerInput, "clearText")
	_performSceneIntro()
	
	
func _performSceneIntro():
	shooter.anim.play("arrive")
	yield(shooter.anim, "animation_finished")
	$AnimationPlayer.play("show_title")
	yield($AnimationPlayer, "animation_finished")
	_startPrepareTextShips()
	_waitAddCreatedShips()


	
func _startPrepareTextShips() -> void:
	var pickedInWave = numShipsWaveFrom + randi() % (numShipsWaveTo - numShipsWaveFrom + 1) 
	var numShips = min(pickedInWave, remainingSceneShips)
	shipsBuilderThread.start(shipsFactory, "generateShips", numShips)
	
	
func _waitAddCreatedShips():
	if (remainingSceneShips > 0):
		var preparedShips: Array = shipsBuilderThread.wait_to_finish()
		_addShipsToScene(preparedShips)
		remainingSceneShips -= (preparedShips.size())
		#start next iteration
		_startPrepareTextShips()
	else: 
		emit_signal("sceneCleared", sceneName)
	
	
func _addShipsToScene(preparedShips: Array):
	for textShip in preparedShips:
		$TextShips.add_child(textShip)
		_registerShipHandlers(textShip)
	currentLiveShips = preparedShips.size()


func _registerShipHandlers(ship: TextShip) -> void:
	ship.connect("textShipCollidedShooter", self, "_finishStageCollided")
	ship.connect("textShipDestroyed", self, "_countDestroyedShip")
	
	
func _input(event: InputEvent) -> void:
	if (not event is InputEventKey):
		return
	var keyEvent: InputEventKey = event as InputEventKey
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = OS.get_scancode_string(keyEvent.scancode)
	
	var specialCodeToggles := _checkSpecialCodes(keyCharCode)
	if (specialCodeToggles.toggleBgMusic):
		$BG/BGMusic.stream_paused = not $BG/BGMusic.stream_paused
	
	if (keyCharCode.length() == 1):
		emit_signal("letterTyped", keyCharCode)

	var shootableWithLetter: Node2D = _findShootableWithNextText(shooter.chamber)
	if (is_instance_valid(shootableWithLetter)):
		shooter.faceShootable(shootableWithLetter)
	if (specialCodeToggles.fireChambered):
		shooter.tryFireAt(shootableWithLetter)
	

func _isKeyJustPressed(keyEvent: InputEventKey) -> bool:
	return not keyEvent.echo and keyEvent.pressed
	

func _findShootableWithNextText(text: String) -> Node2D:
	if (text.empty()):
		return null
	var foundProjectile := _findWithTextInGroup(text, "shootable-projectile")
	if (is_instance_valid(foundProjectile)):
		return foundProjectile
	var foundShip := _findWithTextInGroup(text, "shootable-ship")
	if (is_instance_valid(foundShip)):
		return foundShip
	return null


func _findWithTextInGroup(text: String, group: String) -> Node2D:
	for node in get_tree().get_nodes_in_group(group):
		if (node.nextTextIs(text)):
			return node
	return null
	
	
func _finishStageCollided():
	get_tree().quit()
	
	
func _countDestroyedShip():
	currentLiveShips -= 1
	if (currentLiveShips <= 0):
		yield(get_tree(), "idle_frame")
		_waitAddCreatedShips()
		

func _checkSpecialCodes(keyCode: String) -> Dictionary:
	return {
		'toggleBgMusic': keyCode == "Escape",
		'fireChambered': keyCode == "Space"
	}
	
	
	
