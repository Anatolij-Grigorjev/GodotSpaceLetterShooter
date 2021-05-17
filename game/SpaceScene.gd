extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal waveCleared(waveName)
signal sceneCleared(sceneSpecId)
signal letterTyped(letter)


const StatsViewScn = preload("res://scene_stats/SceneStatsView.tscn")


export(bool) var showStatsBetweenWaves = true


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
var shooterCollided: bool = false


func _ready():
	
	randomize()
	Stats.currentScene = self
	shipsBuilderThread = Thread.new()
	statsCookerThread = Thread.new()
	
	Utils.tryConnect(self, "sceneCleared", Scenes, "_onSceneCleared")
	Utils.tryConnect(self, "waveCleared", self, "_onWaveCleared")
	
	Utils.tryConnect(self, "letterTyped", playerInput, "addTypedLetter")
	Utils.tryConnect(self, "letterTyped", shooter, "chamberLetter")
	
	Utils.tryConnect(shooter, "shotFired", self, "_onShipShotFired")
	Utils.tryConnect(shooter, "chamberEmptied", playerInput, "clearText")
	
	_startNextWave()
	
	
	
	
func setInitialSceneSpec(spec: SceneSpec):
	cachedSpecification = spec
	sceneName = cachedSpecification.sceneName
	nextWaveNumber = 1
	remainingSceneShips = cachedSpecification.totalShips
	remainingSceneShipSpecs = cachedSpecification.allowedShipsTypes.duplicate()


func _prepareNextSceneWaveFromSpec():
	$BG.self_modulate = cachedSpecification.sceneBgColor.darkened(0.25)
	$CanvasLayer/SceneTitle.text = cachedSpecification.sceneName + ("\nWAVE %02d" % nextWaveNumber)
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
	
	
func _emitWaveClear():
	var waveName := "%s - WAVE %02d" % [sceneName, nextWaveNumber - 1]
	emit_signal("waveCleared", waveName)

	
func _waitAddCreatedShips():
	if (remainingSceneShips > 0):
		var preparedShips = shipsBuilderThread.wait_to_finish()
		_addShipsToScene(preparedShips)
		remainingSceneShips -= (preparedShips.size())
	else: 
		_startEndSceneStats()
		_emitWaveClear()
	

func _startEndSceneStats():
	statsCookerThread.start(self, "_buildSceneStats", null)
	stageOver = true
	
	
func _addShipsToScene(preparedShips: Array):
	for textShip in preparedShips:
		$TextShips.add_child(textShip)
		_registerShipHandlers(textShip)
	currentLiveShips = preparedShips.size()


func _registerShipHandlers(ship: TextShip) -> void:
	Stats.connectTextShipStatsSignals(ship)
	Utils.tryConnect(ship, "textShipCollidedShooter", self, "_onShooterCollided")
	Utils.tryConnect(ship, "textShipDestroyed", self, "_countDestroyedShip")
	Utils.tryConnect(ship, "shotFired", self, "_onShipShotFired")
	
	
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
	
	
func _onShipShotFired(projectile: Node2D):
	add_child(projectile)
	#dont count enemy projectiles towards player stats
	if (not projectile.is_in_group("shootable-projectile")):
		Stats.connectProjectileStatsSignals(projectile)
	
	
func _countDestroyedShip(shipText: String):
	currentLiveShips -= 1
	if (currentLiveShips <= 0):
		yield(get_tree(), "idle_frame")
		_startEndSceneStats()
		_emitWaveClear()
		

func _checkSpecialCodes(keyCode: String) -> Dictionary:
	return {
		'fireChambered': keyCode == "Space"
	}
	

func _buildSceneStats(data):
	var statsView = StatsViewScn.instance()
	statsView.sceneName = sceneName
	statsView.setData(Stats.currentSceneStats)
	Utils.tryConnect(statsView, "statsViewKeyPressed", self, "_onStatsViewKeyPressed")
	return statsView
	
	
func _onWaveCleared(waveName: String):
	print("Cleared wave: %s" % waveName)
	shooter.anim.play("leave")
	yield(shooter.anim, "animation_finished")
	yield(get_tree().create_timer(0.75), "timeout")
	var wasLastWave := remainingSceneShips <= 0 or shooterCollided
	if (wasLastWave or showStatsBetweenWaves):
		_addStatsViewToCanvas()
	else:
		_resolvePostWaveStatsActions()
	
	
func _addStatsViewToCanvas():
	var statsView = statsCookerThread.wait_to_finish()
	$CanvasLayer.add_child(statsView)
	
	
func _onShooterCollided():
	if (not stageOver):
		_startEndSceneStats()
		_addStatsViewToCanvas()
	print("scene: '%s' - :(" % sceneName)
	shooterCollided = true
	
	

func _startNextWave():
	currentLiveShips = 0
	stageOver = false
	_prepareNextSceneWaveFromSpec()
	_performWaveIntro()
	
	
func _onStatsViewKeyPressed(statsView: Control):
	statsView.queue_free()
	_resolvePostWaveStatsActions()
	
	
func _resolvePostWaveStatsActions():
	if (shooterCollided):
		get_tree().quit()
	if (remainingSceneShips > 0):
		_startNextWave()
	else:
		print("You are an hero!")
		emit_signal("sceneCleared", cachedSpecification.id)
	
