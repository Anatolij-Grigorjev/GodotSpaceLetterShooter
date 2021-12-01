class_name Mock
"""
Test data fixtures for scenes
"""

static func sceneShiledShips(numShips: int) -> SceneSpec:
	return sceneShipTypeQuantities(0, numShips, 0)
	
static func sceneShooterShips(numShips: int) -> SceneSpec:
	return sceneShipTypeQuantities(0, 0, numShips)
	
	
static func sceneShipTypeQuantities(numFastShips: int = 0 , numShieldShips: int = 0, numShooterShips: int = 0) -> SceneSpec:
	var spec := SceneSpec.new()
	spec.id = "mock"
	spec.order = -1
	spec.sceneName = "MOCK SCENE"
	spec.wordsCorpusPath = "" #use default corpus
	spec.sceneBgColor = Color.cornflower.lightened(rand_range(-0.5, 0.5))
	spec.totalShips = numFastShips + numShieldShips + numShooterShips
	spec.smallestShipsWave = min(2, spec.totalShips)
	spec.largestShipsWave = min(4, spec.totalShips)
	spec.allowedShipsTypes = {
		"fast": numFastShips,
		"shielded": numShieldShips,
		"shooter": numShooterShips
	}
	return spec
