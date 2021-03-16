extends StateMachine
class_name TextShipStateMachine
"""
FSM for actions of a descending ship with text
"""

var hitChars: int = 1

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
			return descendingState.afterCollideEntityState
		"Hit":
			var hitState = getState(state)
			if (hitState.animationFinished):
				return "Descending"
			else:
				return NO_STATE
		"Miss":
			var missState = getState(state)
			if (missState.animationFinished):
				return "Descending"
			else:
				return NO_STATE
		"CollideShip":
			return NO_STATE
		"Die":
			return NO_STATE
		_: 
			breakpoint
			return NO_STATE
