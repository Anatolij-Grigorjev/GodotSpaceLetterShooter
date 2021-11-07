class_name Mapper
"""
Static methods to map JSON bodies into in-game entities
entities cannot do their own mappings due to cyclic dependencies
"""



"""
Turn standard JSON representation of a color 
into an engine Color object
"""
static func parseJSONColor(json: Dictionary) -> Color:
	return Color(
		json.r,
		json.g,
		json.b,
		json.a
	)
	

"""
Turn standard JSON representation of a complete ships scene specification
In an in-game SceneSpec object instance
"""
static func parseJSONSceneSpec(sceneSpecJSON: Dictionary) -> SceneSpec:
	var spec = SceneSpec.new()
	spec.id = sceneSpecJSON.id
	spec.bgType = sceneSpecJSON.background.type
	spec.sceneBgColor = parseJSONColor(sceneSpecJSON.background.tint)
	spec.sceneName = sceneSpecJSON.name
	spec.unlockPoints = sceneSpecJSON.unlockPoints
	spec.wordsCorpusPath = sceneSpecJSON.get('wordsCorpusPath', "")
	spec.smallestShipsWave = sceneSpecJSON.wave.minShips
	spec.largestShipsWave = sceneSpecJSON.wave.maxShips
	spec.shooterTurnsBetweenWaves = sceneSpecJSON.wave.get('turnShip', true)
	for shipTypeBlock in sceneSpecJSON.allowedShipsTypes:
		var shipType = parseJSONShipLimits(shipTypeBlock)
		var numShips = shipTypeBlock.numShips
		spec.allowedShipsTypes[shipType] = numShips
		spec.totalShips += numShips
	return spec
	

"""
Turn standard JSON representation of scene ship type parameters
into an in-game SceneShipLimits instance
"""
static func parseJSONShipLimits(shipLimitsJSON: Dictionary) -> SceneShipLimits:
	return SceneShipLimits.new(
		shipLimitsJSON.speed,
		shipLimitsJSON.shieldHP,
		shipLimitsJSON.shotPriority
	)
	

"""
Turn standard JSON representation of text ship etalon
into an in-game TextShipModel instance

requires model base path since stored paths are relative and object
construction calls 'load()'
"""
static func parseJSONTextShipModel(json: Dictionary, shipsLoadBasePath: String) -> TextShipModel:
	return TextShipModel.new(
		json.id,
		Utils.combinePathParts(shipsLoadBasePath, json.model) + ".tscn",
		json.speed,
		json.shieldHP,
		json.shotPriority
	)
