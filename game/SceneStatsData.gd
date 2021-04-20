class_name SceneStatsData
"""
Statistics about shooter accomplishments in current scene
"""

var sceneName: String
var totalLettersTyped: int
var totalShotsFired: int
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
	shieldsBroken = 0
	projectilesShot = 0
	shipsShot = 0
	totalShipsLetters = 0 
	totalProjectilesLetters = 0 
	longestShipWord = ""
	
	
func _to_string() -> String:
	return """
	 sceneName=%s
	 totalLettersTyped=%s
	 totalShotsFired=%s
	 shieldsBroken=%s
	 projectilesShot=%s
	 shipsShot=%s
	 totalShipsLetters=%s
	 totalProjectilesLetters=%s
	 longestShipWord=%s
""" % [
	sceneName,
	totalLettersTyped,
	totalShotsFired,
	shieldsBroken,
	projectilesShot,
	shipsShot,
	totalShipsLetters,
	totalProjectilesLetters,
	longestShipWord
 ]
