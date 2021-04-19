class_name SceneStatsData
"""
Statistics about shooter accomplishments in current scene
"""

var sceneName: String
var totalShotsFired: int
var shieldsBroken: int
var projectilesShot: int
var shipsShot: int
var totalShipsLetters: int
var totalProjectilesLetters: int
var longestShipWord: String

func _init(sceneName: String):
	self.sceneName = sceneName
	totalShotsFired = 0
	shieldsBroken = 0
	projectilesShot = 0
	shipsShot = 0
	totalShipsLetters = 0 
	totalProjectilesLetters = 0 
	longestShipWord = ""
