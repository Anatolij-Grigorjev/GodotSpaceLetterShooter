extends AnimationState
class_name ShooterShipStartingWaveState
"""
Shooter ship playing correct animation to start the wave
"""


func enterState(prevState: String):
	isActive = true
	if prevState == StateMachine.NO_STATE:
		animationName = "arrive"
		animator.play(animationName)
	else:
		animationName = "transition_wave"
		animator.play_backwards(animationName)

