extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal sceneCleared(sceneName)

const TextShipScn = preload("res://ships/text_ship/TextShip.tscn")

signal letterTyped(letter)



onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput
onready var shipsFactory = $TextShipFactory


var currentLiveShips := 0
var remainingSceneShips := 0
var remainingSceneShipSpecs := {}
var sceneName: String

var shipsBuilderThread: Thread
var statsCookerThread: Thread
var stageOver: bool = false

var specification: SceneSpec


func _ready():
	randomize()
	G.currentScene = self
	shipsBuilderThread = Thread.new()
	statsCookerThread = Thread.new()
	
	Utils.tryConnect(self, "letterTyped", playerInput, "addTypedLetter")
	Utils.tryConnect(self, "letterTyped", shooter, "chamberLetter")
	Utils.tryConnect(self, "sceneCleared", shooter, "_on_currentScene_sceneOver")
	Utils.tryConnect(shooter, "chamberEmptied", playerInput, "clearText")
	Utils.tryConnect(shooter, "shipLeft", self, "_on_sceneCleared")
	Utils.tryConnect(shooter, "shotFired", self, "_on_shipShotFired")
	
	specification = _getSceneSpecification()
	sceneName = specification.sceneName
	$CanvasLayer/SceneTitle.text = specification.sceneName
	
	remainingSceneShips = specification.totalShips
	remainingSceneShipSpecs = specification.allowedShipsTypes.duplicate()
	
	_performSceneIntro()
	
	
func _performSceneIntro():
	shooter.anim.play("arrive")
	yield(shooter.anim, "animation_finished")
	$AnimationPlayer.play("show_title")
	yield($AnimationPlayer, "animation_finished")
	_startPrepareTextShips()
	_waitAddCreatedShips()


func _getSceneSpecification() -> SceneSpec:
	var spec := SceneSpec.new()
	spec.sceneName = "Scene 1 - 1"
	spec.totalShips = 10
	spec.smallestShipsWave = 2
	spec.largestShipsWave = 4
	spec.allowedShipsTypes = {
		#speedster
		SceneShipLimits.new(566, 0, 0): 5,
		#tank 
		SceneShipLimits.new(400.56, 9, 0): 2,
		#shooter
		SceneShipLimits.new(450.0, 1, 3): 3
	}
	
	return spec
	
func _startPrepareTextShips() -> void:
	var numShips = _calcNextWaveNumShips()
	var firstShipStart = Vector2(
		rand_range(100, 175),
		rand_range(50, 100)
	)
	var nextWaveSpec = SceneWaveSpec.new(numShips, firstShipStart, remainingSceneShipSpecs)
	for nextWaveShipSpec in nextWaveSpec.shipTypes:
		remainingSceneShipSpecs[nextWaveShipSpec] -= 1
	shipsBuilderThread.start(shipsFactory, "generateShips", nextWaveSpec)
	


func _calcNextWaveNumShips() -> int:
	var numShipsWaveFrom = specification.smallestShipsWave
	var numShipsWaveTo = specification.largestShipsWave
	var pickedInWave: int = numShipsWaveFrom + randi() % (numShipsWaveTo - numShipsWaveFrom + 1) 
	return int(min(pickedInWave, remainingSceneShips))

	
func _waitAddCreatedShips():
	if (remainingSceneShips > 0):
		var preparedShips: Array = shipsBuilderThread.wait_to_finish()
		_addShipsToScene(preparedShips)
		remainingSceneShips -= (preparedShips.size())
		#start next iteration
		_startPrepareTextShips()
	else: 
		_startEndSceneStats()
		emit_signal("sceneCleared", sceneName)
	

func _startEndSceneStats():
	statsCookerThread.start(self, "_buildSceneStats", null)
	stageOver = true
	
	
func _addShipsToScene(preparedShips: Array):
	for textShip in preparedShips:
		$TextShips.add_child(textShip)
		_registerShipHandlers(textShip)
	currentLiveShips = preparedShips.size()


func _registerShipHandlers(ship: TextShip) -> void:
	G.connectTextShipStatsSignals(ship)
	Utils.tryConnect(ship, "textShipCollidedShooter", self, "_on_shooterCollided")
	Utils.tryConnect(ship, "textShipDestroyed", self, "_countDestroyedShip")
	Utils.tryConnect(ship, "shotFired", self, "_on_shipShotFired")
	
	
func _input(event: InputEvent) -> void:
	if (stageOver):
		return
	if (not event is InputEventKey):
		return
	var keyEvent: InputEventKey = event as InputEventKey
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = OS.get_scancode_string(keyEvent.scancode)
	
	var specialCodeToggles := _checkSpecialCodes(keyCharCode)
	
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
	
	
func _on_shipShotFired(projectile: Node2D):
	add_child(projectile)
	if (projectile.is_in_group("shootable-projectile")):
		G.connectProjectileStatsSignals(projectile)
	
	
func _countDestroyedShip(shipText: String):
	currentLiveShips -= 1
	if (currentLiveShips <= 0):
		yield(get_tree(), "idle_frame")
		_waitAddCreatedShips()
		

func _checkSpecialCodes(keyCode: String) -> Dictionary:
	return {
		'fireChambered': keyCode == "Space"
	}
	

func _buildSceneStats(data):
	var StatsScn: PackedScene = load("res://SceneStatsView.tscn")
	var statsView = StatsScn.instance()
	statsView.sceneName = sceneName
	statsView.setData(G.currentSceneStats)
	return statsView
	
	
func _on_sceneCleared():
	_addStatsViewToCanvas()
	print("Cleared scene: %s" % sceneName)
	print("You are an hero!")
	
	
func _addStatsViewToCanvas():
	yield(get_tree().create_timer(0.75), "timeout")
	var statsView = statsCookerThread.wait_to_finish()
	$CanvasLayer.add_child(statsView)
	
	
func _on_shooterCollided():
	if (not stageOver):
		_startEndSceneStats()
		_addStatsViewToCanvas()
	print("scene: '%s' - :(" % sceneName)
