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
			if stateNode.statsViewClosed:
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
		rand_range(100, 175),
		rand_range(50, 100)
	)
	var nextWaveSpec = SceneWaveSpec.new(numShips, firstShipStart, remainingSceneShipSpecs)
	for nextWaveShipSpec in nextWaveSpec.shipTypes:
		remainingSceneShipSpecs[nextWaveShipSpec] -= 1
	return nextWaveSpec


func _calcNextWaveNumShips() -> int:
	var numShipsWaveFrom = sceneSpecification.smallestShipsWave
	var numShipsWaveTo = sceneSpecification.largestShipsWave
	var pickedInWave: int = numShipsWaveFrom + randi() % (numShipsWaveTo - numShipsWaveFrom + 1) 
	return int(min(pickedInWave, remainingSceneShips))
	
	
func _onShipShotFired(projectile: Node2D):
	entity.add_child(projectile)
	#dont count enemy projectiles towards player stats
	if (not projectile.is_in_group("shootable-projectile")):
		Stats.connectProjectileStatsSignals(projectile)
