class_name Mock
"""
Test data fixtures for scenes
"""

static func sceneShiledShips(numShips: int) -> SceneSpec:
	var spec := SceneSpec.new()
	spec.sceneName = "SPACE"
	spec.sceneBgColor = Color.cornflower
	spec.totalShips = numShips
	spec.smallestShipsWave = 2
	spec.largestShipsWave = 4
	spec.allowedShipsTypes = {
		#speedster
		SceneShipLimits.new(566, 0, 0): 0,
		#tank 
		SceneShipLimits.new(400.56, 9, 0): numShips,
		#shooter
		SceneShipLimits.new(450.0, 1, 3): 0
	}
	return spec
