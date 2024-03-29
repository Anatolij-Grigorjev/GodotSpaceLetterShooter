class_name SceneSpec
"""
Parameters describing how to construct a scene:
	- what to name it
	- how many ships there are and how many per wave
	- what kinds of ships are in this scene (shooting/passive, shield strength, etc)
"""
var id: String
var order: int
var bgType: String
var sceneName: String
var unlocksAfter: Array
var wordsCorpusPath: String
var sceneBgColor: Color
var totalShips: int
var smallestShipsWave: int
var largestShipsWave: int
var shooterTurnsBetweenWaves: bool
"""
SceneShipLimits mapped to how many of this kind of type is allowed
"""
var allowedShipsTypes: Dictionary


func _init():
	id = "mock"
	order = 0
	bgType = "space"
	sceneName = "<EMPTY>"
	unlocksAfter = []
	wordsCorpusPath = ""
	sceneBgColor = Color.black
	totalShips = 0
	smallestShipsWave = 0
	largestShipsWave = 0
	shooterTurnsBetweenWaves = true
	allowedShipsTypes = {}
