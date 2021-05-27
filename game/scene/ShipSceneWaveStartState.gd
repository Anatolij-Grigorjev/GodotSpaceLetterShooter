extends State
class_name ShipSceneWaveStartState
"""
State to perform required animations and startups for next wave
"""

var waveNumber: int = 0
var waveSpec: SceneWaveSpec
var shipsBuilderThread: Thread
var shipsAdded: bool = false


func enterState(prevState: String):
	.enterState(prevState)
	_prepareWaveBGAndTitle()
	_assertCreateWaveState()
	shipsBuilderThread = entity.shipsFactory.startGenerateShipsAsync(waveSpec)
	yield(_playWaveIntroAnimations(), "completed")
	
	
func _prepareWaveBGAndTitle():
	entity.get_node('BG').self_modulate = entity.cachedSpecification.sceneBgColor.darkened(0.25)
	entity.get_node('CanvasLayer/SceneTitle').text = entity.cachedSpecification.sceneName + ("\nWAVE %02d" % waveNumber)
	
	
func _playWaveIntroAnimations():
	entity.shooter.anim.play("arrive")
	yield(entity.shooter.anim, "animation_finished")
	entity.get_node('AnimationPlayer').play("show_title")
	yield(entity.get_node('AnimationPlayer'), "animation_finished")
	
	
	
func processState(delta: float):
	.processState(delta)
	if (shipsAdded or shipsBuilderThread.is_active()):
		return
	var ships: Array = shipsBuilderThread.wait_to_finish()
	entity._addShipsToScene(ships)
	shipsAdded = true
	
	
	
func exitState(nextState: String):
	_resetState()
	entity.musicControl.currentlyPlaying = true
	.exitState(nextState)
	
	
func _resetState():
	waveNumber = 0
	waveSpec = null
	shipsBuilderThread = null
	shipsAdded = false
	
	
func _assertCreateWaveState():
	assert(waveNumber != 0)
	assert(waveSpec)
	assert(not shipsAdded)
