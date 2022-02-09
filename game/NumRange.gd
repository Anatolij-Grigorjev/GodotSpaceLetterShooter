class_name NumRange
"""
Simple range class that has min and max values. 
Partially Functions like a Vector2, but more descriptive for its own
purpouses
"""

var minVal: int = 0
var maxVal: int = 0

func _init(minVal, maxVal):
	self.minVal = minVal
	self.maxVal = clamp(maxVal, self.minVal, maxVal)
	
	
func empty() -> bool:
	return minVal >= maxVal
	
"""
Sample random value from within the range
In case of empty range throws error
"""
func random() -> float:
	assert(not empty())
	return minVal + randf() * size()
	

"""
Get current size of range (breadth of values between smallest and largest)
"""
func size() -> float:
	return abs(maxVal - minVal)


