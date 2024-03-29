extends StateMachine
class_name ShipSceneStateMachine
"""
FSM for controlling distinct phases during a ship scene
"""

var sceneSpecification: SceneSpec setget setSceneSpec
var remainingSceneShips := 0
var remainingSceneShipSpecs := {}
var shooterFailed: bool = false
var waveNumber: int = 0


func _ready():
	randomize()
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
				waveNumber = 1
				_setNextWaveSpec(waveNumber)
				return "WaveStart"
			else:
				return "SceneEnd"
		"WaveStart":
			if stateNode.shipsAdded:
				return "WaveProcess"
			return NO_STATE
		"WaveProcess":
			if stateNode.waveOver:
				return "WaveEnd"
			return NO_STATE
		"WaveEnd":
			if stateNode.shipLeft:
				var wasLastWave = shooterFailed or remainingSceneShips <= 0
				if (wasLastWave):
					return "SceneEnd"
				else:
					waveNumber += 1
					_setNextWaveSpec(waveNumber)
					return "WaveStart"
			return NO_STATE
		"SceneEnd":
			return NO_STATE
		_:
			breakpoint
			return NO_STATE


func _setNextWaveSpec(waveNumber: int):
	var waveStartState: ShipSceneWaveStartState = getState("WaveStart")
	waveStartState.waveNumber = waveNumber
	waveStartState.waveSpec = _buildNextWaveSpec()
	remainingSceneShips -= waveStartState.waveSpec.numShips
	

func _buildNextWaveSpec() -> SceneWaveSpec:
	var numShips = _calcNextWaveNumShips()
	var firstShipStart = Vector2(
		rand_range(175, 200),
		rand_range(100, 150)
	)
	var nextWaveSpec = SceneWaveSpec.new(numShips, firstShipStart, remainingSceneShipSpecs)
	for nextWaveShipSpec in nextWaveSpec.shipTypes:
		remainingSceneShipSpecs[nextWaveShipSpec] -= 1
	return nextWaveSpec


func _calcNextWaveNumShips() -> int:
	var numShipsWaveFrom = sceneSpecification.smallestShipsWave
	var numShipsWaveTo = sceneSpecification.largestShipsWave
	var numShipsPickedForWave = 0
	#use all remaining ships in next wave if there are not many left
	if (remainingSceneShips <= numShipsWaveTo):
		numShipsPickedForWave = remainingSceneShips
	else:
		numShipsPickedForWave = numShipsWaveFrom + randi() % (numShipsWaveTo - numShipsWaveFrom + 1) 
	return int(min(numShipsPickedForWave, remainingSceneShips))
	

func _onShipDroppedLetter(letterNode: Node2D):
	entity.textShipsContainer.add_child(letterNode)

	
func _onShipShotFired(projectile: Node2D):
	entity.add_child(projectile)
	entity.freeze.startFreeze(0.035)
	#dont count enemy projectiles towards player stats
	if (not projectile.is_in_group("shootable-projectile")):
		Stats.connectProjectileStatsSignals(projectile)
