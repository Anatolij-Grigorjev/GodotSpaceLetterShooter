class_name SceneSpec
"""
Parameters describing how to construct a scene:
	- what to name it
	- how many ships there are and how many per wave
	- what kinds of ships are in this scene (shooting/passive, shield strength, etc)
"""

var sceneName: String
var totalShips: int
var smallestShipsWave: int
var largestShipsWave: int
"""
SceneShipLimits mapped to how many of this kind of type is allowed
"""
var allowedShipsTypes: Dictionary


func _init():
	sceneName = "<EMPTY>"
	totalShips = 0
	smallestShipsWave = 0
	largestShipsWave = 0
	allowedShipsTypes = {}
