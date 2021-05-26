extends State
class_name ShipSceneWaveStartState
"""
State to perform required animations and startups for next wave
"""

var waveNumber: int = 0

func enterState(prevState: String):
	.enterState(prevState)
	_prepareNextWaveBGAndTitle()
	yield(_playWaveIntroAnimations(), "completed")
	
	
func _prepareNextWaveBGAndTitle():
	entity.get_node('BG').self_modulate = entity.cachedSpecification.sceneBgColor.darkened(0.25)
	entity.get_node('CanvasLayer/SceneTitle').text = entity.cachedSpecification.sceneName + ("\nWAVE %02d" % waveNumber)
	
	
func _playWaveIntroAnimations():
	entity.shooter.anim.play("arrive")
	yield(entity.shooter.anim, "animation_finished")
	entity.get_node('AnimationPlayer').play("show_title")
	yield(entity.get_node('AnimationPlayer'), "animation_finished")
	
	
	
func exitState(nextState: String):
	entity.musicCntrol.currentlyPlaying = true
	.exitState(nextState)
