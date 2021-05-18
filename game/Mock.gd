class_name Mock
"""
Test data fixtures for scenes
"""

static func sceneShiledShips(numShips: int) -> SceneSpec:
	return sceneShipTypeQuantities(0, numShips, 0)
	
	
static func sceneShipTypeQuantities(numFastShips: int= 0 , numShieldShips: int = 0, numShooterShips: int = 0) -> SceneSpec:
	var spec := SceneSpec.new()
	spec.id = 1000 + (1 * numFastShips) + (2 * numShieldShips) + (4 * numShooterShips)
	spec.sceneName = "SPACE"
	spec.sceneBgColor = Color.cornflower.lightened(rand_range(-0.5, 0.5))
	spec.totalShips = numFastShips + numShieldShips + numShooterShips
	spec.smallestShipsWave = min(2, spec.totalShips)
	spec.largestShipsWave = min(4, spec.totalShips)
	spec.allowedShipsTypes = {
		#speedster
		SceneShipLimits.new(566, 0, 0): numFastShips,
		#tank 
		SceneShipLimits.new(400.56, 4, 0): numShieldShips,
		#shooter
		SceneShipLimits.new(450.0, 1, 3): numShooterShips
	}
	return spec
