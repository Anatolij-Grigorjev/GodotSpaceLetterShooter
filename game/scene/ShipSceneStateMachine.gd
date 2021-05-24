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
	match(state):
		"SceneStart":
			return NO_STATE
		"WaveProcess":
			return NO_STATE
		"WaveSwitch":
			return NO_STATE
		"SceneEnd":
			return NO_STATE
		_:
			breakpoint
			return NO_STATE
