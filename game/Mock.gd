class_name Mock
"""
Test data fixtures for scenes
"""

static func sceneShiledShips(numShips: int) -> SceneSpec:
	return sceneShipTypeQuantities(0, numShips, 0)
	
	
static func sceneShipTypeQuantities(numFastShips: int, numShieldShips: int, numShooterShips: int) -> SceneSpec:
	var spec := SceneSpec.new()
	spec.id = 1000 + (1 * numFastShips) + (2 * numShieldShips) + (4 * numShooterShips)
	spec.sceneName = "SPACE"
	spec.sceneBgColor = Color.cornflower
	spec.totalShips = numFastShips + numShieldShips + numShooterShips
	spec.smallestShipsWave = 2
	spec.largestShipsWave = 4
	spec.allowedShipsTypes = {
		#speedster
		SceneShipLimits.new(566, 0, 0): numFastShips,
		#tank 
		SceneShipLimits.new(400.56, 4, 0): numShieldShips,
		#shooter
		SceneShipLimits.new(450.0, 1, 3): numShooterShips
	}
	return spec
