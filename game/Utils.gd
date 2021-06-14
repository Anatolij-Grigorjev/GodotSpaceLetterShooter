class_name Utils
"""
Static utility methods
"""


"""
Join elements of an Array as a string  using the 
'joiner' delimiter.
Each element is stringified using the 'formatter' format string.
"""
static func joinToString(
	col: Array, joiner = ",", formatter: String = "%s"
) -> String:
	var stringPool := PoolStringArray()
	for item in col:
		stringPool.append(formatter % item)
	return stringPool.join(joiner)

"""
Print current values stored in listed object properties,
one property=value pair per line
"""
static func dumpObjectScriptVars(object: Object) -> String:
	var currentPropValues := ["<%s>" % object.get_class()]
	for prop in object.get_property_list():
		if (prop.usage == PROPERTY_USAGE_SCRIPT_VARIABLE):
			currentPropValues.append("\t%s=%s" % [prop.name, object.get(prop.name)])
	currentPropValues.append("</%s>" % object.get_class())
	
	return joinToString(currentPropValues, "\n")
	

"""
Attempt to connect 'signal' from 'source' to 'method' on 'target', 
with specified binds.
NOOP if connection exists. 
default connect flags.
Returns 'true' if a new signal connection was made, 'false' otherwise
"""
static func tryConnect(
	source: Object, sourceSignal: String, 
	target: Object, method: String,
	binds: Array = []
) -> bool:
	if (source.is_connected(sourceSignal, target, method)):
		return false
	var connectError = source.connect(sourceSignal, target, method, binds)
	if (connectError != OK):
		print("CONNECT_ERROR: %s emit '%s' -> %s handler '%s': %s" % [
			source.name, sourceSignal,
			target.name, method,
			connectError
		])
	else:
		print("CONNECT: %s emit '%s' -> %s handler '%s'" % [
			source.name, sourceSignal, target.name, method
		])
	return connectError == OK


"""
Get contents of file as a string
"""
static func getFileText(filePath: String) -> String:
	var file: File = File.new()
	var fileOpenError = file.open(filePath, File.READ)
	if fileOpenError != OK:
		print("Error opening file at '%s'! Error code: %s" % [filePath, fileOpenError])
		breakpoint
	var fileText: String = file.get_as_text()
	file.close()
	return fileText
	


"""
Check if a given animator instance is currently playing the animation with
specified name
"""
static func animIsPlayingAnimation(anim: AnimationPlayer, animationName: String) -> bool:
	return anim.is_playing() and anim.current_animation == animationName
	

	
"""
Parse the file at path 'filePath' as valid JSON and return the structure
(list of object)
"""
static func file2JSON(filePath: String):
	var fileText: String = getFileText(filePath)
	var parseResult: JSONParseResult = JSON.parse(fileText)
	if parseResult.error != OK:
		print("Error parsing JSON string!\n%s.\nError code: %s, '%s' on line: %s" % [
			fileText,
			parseResult.error,
			parseResult.error_string,
			parseResult.error_line
		])
		breakpoint
	return parseResult.result
	
	
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
	spec.type = sceneSpecJSON.type
	spec.sceneName = sceneSpecJSON.name
	spec.sceneBgColor = parseJSONColor(sceneSpecJSON.bgColor)
	spec.smallestShipsWave = sceneSpecJSON.minShipsWave
	spec.largestShipsWave = sceneSpecJSON.maxShipsWave
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
Generate random Vector2 with coordinates between
(-range_x;-range_y) and (range_x;range_y)
"""
static func rand_point(range_x: float, range_y: float) -> Vector2:
	return Vector2(
		rand_range(-range_x, range_x),
		rand_range(-range_y, range_y)
	)
