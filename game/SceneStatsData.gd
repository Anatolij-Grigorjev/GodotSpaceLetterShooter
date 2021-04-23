class_name SceneStatsData
"""
Statistics about shooter accomplishments in current scene
"""

var sceneName: String
var totalLettersTyped: int
var totalShotsFired: int
var totalShotsMissed: int
var shieldsBroken: int
var projectilesShot: int
var shipsShot: int
var totalShipsLetters: int
var totalProjectilesLetters: int
var longestShipWord: String

func _init(sceneName: String):
	self.sceneName = sceneName
	totalLettersTyped = 0
	totalShotsFired = 0
	totalShotsMissed = 0
	shieldsBroken = 0
	projectilesShot = 0
	shipsShot = 0
	totalShipsLetters = 0 
	totalProjectilesLetters = 0 
	longestShipWord = ""
	
	
func get_class() -> String:
	return "SceneStatsData"
	
func _to_string() -> String:
	return Utils.dumpObjectScriptVars(self)
