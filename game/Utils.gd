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
