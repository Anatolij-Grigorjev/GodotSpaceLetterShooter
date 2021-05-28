extends State
class_name ShipSceneStartState
"""
State behavior describing actions for a scene to startup 
and leading up to first wave
"""


func enterState(prevState: String):
	.enterState(prevState)
	
	assert(fsm.cachedSpecification)
	
	Utils.tryConnect(entity, "sceneCleared", Scenes, "_onSceneCleared")
	Utils.tryConnect(entity, "sceneFailed", Scenes, "_onSceneFailed")
	
	Utils.tryConnect(entity, "letterTyped", entity.playerInput, "addTypedLetter")
	Utils.tryConnect(entity, "letterTyped", entity.shooter, "chamberLetter")
	
	Utils.tryConnect(entity.shooter, "shotFired", entity, "_onShipShotFired")
	Utils.tryConnect(entity.shooter, "chamberEmptied", entity.playerInput, "clearText")
	
	
func exitState(nextState: String):
	.exitState(nextState)
	#no ships found, next state is ending scene without waves
	if (nextState == "SceneEnd"):
		return
	
	var waveStartState: ShipSceneWaveStartState = fsm.getState(nextState)
	waveStartState.waveNumber = 1
	waveStartState.waveSpec = _buildFirstWaveSpec()
	
	
func _buildFirstWaveSpec() -> SceneWaveSpec:
	var numShips = _calcNextWaveNumShips()
	var firstShipStart = Vector2(
		rand_range(100, 175),
		rand_range(50, 100)
	)
	var nextWaveSpec = SceneWaveSpec.new(numShips, firstShipStart, entity.remainingSceneShipSpecs)
	for nextWaveShipSpec in nextWaveSpec.shipTypes:
		fsm.remainingSceneShipSpecs[nextWaveShipSpec] -= 1
	fsm.remainingSceneShips -= numShips
	return nextWaveSpec


func _calcNextWaveNumShips() -> int:
	var numShipsWaveFrom = fsm.cachedSpecification.smallestShipsWave
	var numShipsWaveTo = fsm.cachedSpecification.largestShipsWave
	var pickedInWave: int = numShipsWaveFrom + randi() % (numShipsWaveTo - numShipsWaveFrom + 1) 
	return int(min(pickedInWave, fsm.remainingSceneShips))
