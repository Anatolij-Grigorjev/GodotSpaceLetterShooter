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
	col: Array, formatter: String = "%s", joiner = ","
) -> String:
	var stringPool := PoolStringArray()
	for item in col:
		stringPool.append(formatter % item)
	return stringPool.join(joiner)


"""
Attempt to connect 'signal' from 'source' to 'method' on 'target'.
NOOP if connection exists. 
No additonal binds provided, default connect flags.
Returns 'true' if a new signal connection was made, 'false' otherwise
"""
static func tryConnect(
	source: Object, sourceSignal: String, 
	target: Object, method: String
) -> bool:
	if (source.is_connected(sourceSignal, target, method)):
		return false
	var connectError = source.connect(sourceSignal, target, method)
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
