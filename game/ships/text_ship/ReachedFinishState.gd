extends AnimationState
class_name ReachedFinishState
"""
State script for text shi when it reaches the finish area
"""

func enterState(prevState: String):
	.enterState(prevState)
	entity.emit_signal("textShipReachedFinish")
