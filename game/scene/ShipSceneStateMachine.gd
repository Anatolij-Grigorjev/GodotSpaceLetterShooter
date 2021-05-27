extends StateMachine
class_name ShipSceneStateMachine
"""
FSM for controlling distinct phases during a ship scene
"""

var cachedSpecification: SceneSpec

var remainingSceneShips: int


func _ready():
	randomize()
	Stats.currentScene = entity
	call_deferred("setState", "SceneStart")
	

func _getNextState(delta: float) -> String:
	var stateNode = stateNodes[state] as State
	match(state):
		"SceneStart":
			if (remainingSceneShips > 0):
				return "WaveStart"
			else:
				return "SceneEnd"
		"WaveStart":
			
			return NO_STATE
		"WaveProcess":
			return NO_STATE
		"WaveEnd":
			return NO_STATE
		"SceneEnd":
			return NO_STATE
		_:
			breakpoint
			return NO_STATE
