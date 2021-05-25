extends State
class_name ShipSceneWaveStartState
"""
State to perform required animations and startups for next wave
"""

func enterState(prevState: String):
	.enterState(prevState)
	entity._prepareNextWaveBGAndTitle()
	yield(entity._playWaveIntroAnimations(), "completed")
	
	
	
func exitState(nextState: String):
	entity.musicCntrol.currentlyPlaying = true
	.exitState(nextState)
