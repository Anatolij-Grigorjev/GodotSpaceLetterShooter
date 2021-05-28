extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal sceneCleared(sceneSpecId)
signal sceneFailed(sceneSpecId)
signal letterTyped(letter)


const StatsViewScn = preload("res://scene_stats/SceneStatsView.tscn")


export(bool) var showStatsBetweenWaves = true


onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput
onready var musicControl = $CanvasLayer/MusicControl
onready var shipsFactory = $TextShipFactory


var fsm: ShipSceneStateMachine

var statsCookerThread: Thread
var stageOver: bool = false


func _ready():
	
	randomize()
	Stats.currentScene = self
	statsCookerThread = Thread.new()
	
	

func setSceneSpecificaion(spec: SceneSpec):
	fsm.sceneSpecification = spec



	
func _waitAddCreatedShips():
	if (remainingSceneShips > 0):
		var preparedShips = shipsBuilderThread.wait_to_finish()
		_addShipsToScene(preparedShips)
		remainingSceneShips -= (preparedShips.size())
	else: 
		_startEndSceneStats()
		var waveName := "%s - WAVE %02d" % [sceneName, nextWaveNumber - 1]
		_onWaveCleared(waveName)
	

func _startEndSceneStats():
	statsCookerThread.start(self, "_buildSceneStats", null)
	stageOver = true



	

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
	
	

func _startNextWave():
	currentLiveShips = 0
	stageOver = false
	_prepareNextWaveBGAndTitle()
	_playWaveIntroAnimations()
	
	
func _onStatsViewKeyPressed(statsView: Control):
	statsView.queue_free()
	_resolvePostWaveStatsActions()
	
	
func _resolvePostWaveStatsActions():
	if (remainingSceneShips > 0 and not shooterCollided):
		_startNextWave()
	else:
		var correctSceneEndSignal = (
			"sceneCleared" if not shooterCollided
			else "sceneFailed"
		)
		emit_signal(correctSceneEndSignal, cachedSpecification.id)
	
