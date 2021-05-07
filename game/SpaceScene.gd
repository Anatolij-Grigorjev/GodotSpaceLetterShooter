extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal waveCleared(waveName)
signal clearedAllWaves
signal letterTyped(letter)


const TextShipScn = preload("res://ships/text_ship/TextShip.tscn")


export(int) var totalSceneWaves: int = 5


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

var cachedSpecification: SceneSpec
var nextWaveNumber: int = 0


func _ready():
	
	randomize()
	G.currentScene = self
	shipsBuilderThread = Thread.new()
	statsCookerThread = Thread.new()
	
	Utils.tryConnect(self, "letterTyped", playerInput, "addTypedLetter")
	Utils.tryConnect(self, "letterTyped", shooter, "chamberLetter")
	Utils.tryConnect(self, "waveCleared", shooter, "_on_currentScene_waveOver")
	Utils.tryConnect(shooter, "chamberEmptied", playerInput, "clearText")
	Utils.tryConnect(shooter, "shipLeft", self, "_on_waveCleared")
	Utils.tryConnect(shooter, "shotFired", self, "_on_shipShotFired")
	
	_startNextWave()
	
	
	
	
func setInitialSceneSpec(spec: SceneSpec):
	cachedSpecification = spec
	sceneName = cachedSpecification.sceneName
	nextWaveNumber = 1
	remainingSceneShips = cachedSpecification.totalShips
	remainingSceneShipSpecs = cachedSpecification.allowedShipsTypes.duplicate()


func _prepareNextSceneWaveFromSpec():
	$BG.self_modulate = cachedSpecification.sceneBgColor.darkened(0.25)
	$CanvasLayer/SceneTitle.text = cachedSpecification.sceneName + ("\nWave %02d" % nextWaveNumber)
	nextWaveNumber += 1

	
func _performWaveIntro():
	shooter.anim.play("arrive")
	yield(shooter.anim, "animation_finished")
	$AnimationPlayer.play("show_title")
	yield($AnimationPlayer, "animation_finished")
	_startPrepareTextShips()
	_waitAddCreatedShips()
	
	
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
	var numShipsWaveFrom = cachedSpecification.smallestShipsWave
	var numShipsWaveTo = cachedSpecification.largestShipsWave
	var pickedInWave: int = numShipsWaveFrom + randi() % (numShipsWaveTo - numShipsWaveFrom + 1) 
	return int(min(pickedInWave, remainingSceneShips))

	
func _waitAddCreatedShips():
	if (remainingSceneShips > 0):
		var preparedShips = shipsBuilderThread.wait_to_finish()
		_addShipsToScene(preparedShips)
		remainingSceneShips -= (preparedShips.size())
		if (remainingSceneShips > 0):
			#start next iteration
			_startPrepareTextShips()
	else: 
		_startEndSceneStats()
		emit_signal("waveCleared", sceneName)
	

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
	Utils.tryConnect(statsView, "statsViewKeyPressed", self, "_on_statsViewKeyPressed")
	return statsView
	
	
func _on_waveCleared():
	_addStatsViewToCanvas()
	print("Cleared wave: %s" % sceneName)
	
	
func _addStatsViewToCanvas():
	yield(get_tree().create_timer(0.75), "timeout")
	var statsView = statsCookerThread.wait_to_finish()
	$CanvasLayer.add_child(statsView)
	
	
func _on_shooterCollided():
	if (not stageOver):
		_startEndSceneStats()
		_addStatsViewToCanvas()
	print("scene: '%s' - :(" % sceneName)
	

func _startNextWave():
	currentLiveShips = 0
	stageOver = false
	_prepareNextSceneWaveFromSpec()
	_performWaveIntro()
	
	
func _on_statsViewKeyPressed(statsView: Control):
	statsView.queue_free()
	nextWaveNumber += 1
	if (nextWaveNumber <= totalSceneWaves):
		_startNextWave()
	else:
		emit_signal("clearedAllWaves")
		print("You are an hero!")
		get_tree().quit()
	
