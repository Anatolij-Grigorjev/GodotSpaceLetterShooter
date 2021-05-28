extends StateMachine
class_name ShipSceneStateMachine
"""
FSM for controlling distinct phases during a ship scene
"""

var sceneSpecification: SceneSpec setget setSceneSpec
var remainingSceneShips := 0
var remainingSceneShipSpecs := {}


func _ready():
	randomize()
	Stats.currentScene = entity
	call_deferred("setState", "SceneStart")
	
	
func setSceneSpec(spec: SceneSpec):
	sceneSpecification = spec
	remainingSceneShips = sceneSpecification.totalShips
	remainingSceneShipSpecs = sceneSpecification.allowedShipsTypes.duplicate()
	

func _getNextState(delta: float) -> String:
	var stateNode = stateNodes[state] as State
	match(state):
		"SceneStart":
			if (remainingSceneShips > 0):
				
				return "WaveStart"
			else:
				return "SceneEnd"
		"WaveStart":
			var waveStartState = stateNode as ShipSceneWaveStartState
			if waveStartState.shipsAdded:
				return "WaveProcess"
			return NO_STATE
		"WaveProcess":
			var waveProcessState = stateNode as ShipSceneWaveProcessState
			if waveProcessState.waveOver:
				return "WaveEnd"
			return NO_STATE
		"WaveEnd":
			return NO_STATE
		"SceneEnd":
			return NO_STATE
		_:
			breakpoint
			return NO_STATE
