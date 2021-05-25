extends StateMachine
class_name ShipSceneStateMachine
"""
FSM for controlling distinct phases during a ship scene
"""

func _ready():
	randomize()
	Stats.currentScene = entity
	call_deferred("setState", "SceneStart")
	

func _getNextState(delta: float) -> String:
	var stateNode = stateNodes[state] as State
	match(state):
		"SceneStart":
			# in this method the enterState was already invoked, so 
			# state is done
			return "WaveStart"
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
