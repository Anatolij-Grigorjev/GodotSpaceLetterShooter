extends StateMachine
class_name TextShipStateMachine
"""
FSM for actions of a descending ship with text
"""


# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("setState", "Appearing")


func _getNextState(delta: float) -> String:
	match (state):
		"Appearing":
			var appearingState = getState(state)
			if (appearingState.animationFinished):
				return "Descending"
			else:
				return NO_STATE
		"Descending":
			var descendingState = getState(state)
			return NO_STATE
		_: 
			return NO_STATE
			
			
