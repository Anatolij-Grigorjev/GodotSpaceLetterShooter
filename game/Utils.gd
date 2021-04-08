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
