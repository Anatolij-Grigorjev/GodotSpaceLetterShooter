extends State
class_name ShipSceneWaveStartState
"""
State to perform required animations and startups for next wave
"""

var waveNumber: int = 0
var waveSpec: SceneWaveSpec
var shipsBuilderThread: Thread
var shipsAdded: bool = false
var introsDone: bool = false


func _ready():
	shipsBuilderThread = Thread.new()


func enterState(prevState: String):
	.enterState(prevState)
	_prepareWaveTitle()
	_assertCreateWaveState()
	shipsBuilderThread.start(entity.shipsFactory, "generateShips", waveSpec)
	yield(_playWaveIntroAnimations(), "completed")
	
	
func _prepareWaveTitle():
	entity.get_node('CanvasLayer/SceneTitle').text = fsm.sceneSpecification.sceneName + ("\nWAVE %02d" % waveNumber)
	
	
func _playWaveIntroAnimations():
	entity.shooter.startNextWave()
	yield(get_tree(), "idle_frame")
	yield(entity.shooter.fsm, "stateChanged")
	entity.animator.play("show_title")
	yield(entity.animator, "animation_finished")
	introsDone = true
	
	
	
func processState(delta: float):
	.processState(delta)
	if (not introsDone or shipsAdded):
		return
	var ships: Array = shipsBuilderThread.wait_to_finish()
	_addSceneShips(ships)
	shipsAdded = true
	
	
func _addSceneShips(ships: Array):
	var shipsContainer = entity.textShipsContainer
	for node in ships:
		shipsContainer.add_child(node)
		Utils.tryConnect(entity, "letterTyped", node, "_pulseTarget")
		Utils.tryConnect(node, "shipHit", entity, "_onTextShipHit")
		Utils.tryConnect(node, "shipHitEarnedPoints", entity, "_onTextShipPointsEarned")
	
	
func exitState(nextState: String):
	_resetState()
	entity.musicControl.currentlyPlaying = true
	.exitState(nextState)
	
	
func _resetState():
	waveNumber = 0
	waveSpec = null
	shipsAdded = false
	introsDone = false
	
	
func _assertCreateWaveState():
	assert(waveNumber != 0)
	assert(waveSpec)
	assert(not introsDone)
	assert(not shipsAdded)
