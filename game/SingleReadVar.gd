class_name SingleReadVar
"""
Value container that can be written into and resets on read
"""

var emptyValue
var _currentValue

"""
Create new instance of SingleReadVar with given 'empty value'
"""
func _init(emptyValue):
	self.emptyValue = emptyValue
	_reset()


"""
Check if the current value of the single read cell equals the init value
"""
func empty() -> bool:
	return equals(emptyValue)
	

"""
Write new value into the single read cell, overriding whatever was before
"""
func write(newValue):
	self._currentValue = newValue
	

"""
Read the value from the single read cell. This returns the value and resets 
the cell to 'empty'
"""	
func readAndReset():
	var value = self._currentValue
	_reset()
	return value
	

"""
Check if currently stored value in cell equals another value.
Does not reset the cell
"""
func equals(other) -> bool:
	return _currentValue == other
	
	
func _reset():
	_currentValue = emptyValue
