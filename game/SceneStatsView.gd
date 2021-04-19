tool
extends Control

export(String) var sceneName: String = "<SCENE NAME>" setget setSceneName


func _ready():
	pass


func setData(data: SceneStatsData):
	$Panel/MarginFrame/TitleAndStats/GridContainer/ShotsFiredValue.text = data.totalShotsFired
	$Panel/MarginFrame/TitleAndStats/GridContainer/ShieldsBrokenValue.text = data.shieldsBroken
	$Panel/MarginFrame/TitleAndStats/GridContainer/ShipsDestroyedValue.text = data.shipsShot
	$Panel/MarginFrame/TitleAndStats/GridContainer/ProjectilesDestroyedValue.text = data.projectilesShot
	$Panel/MarginFrame/TitleAndStats/GridContainer/TotalShipsLettersValue.text = "%s/%s" % [data.totalShipsLetters, (data.totalShipsLetters + data.totalProjectilesLetters)]
	$Panel/MarginFrame/TitleAndStats/GridContainer/LongestShipWordValue.text = data.longestShipWord
	

func setSceneName(name: String):
	if ($Panel/MarginFrame/TitleAndStats/Title):
		$Panel/MarginFrame/TitleAndStats/Title.text = "\"%s\" STATISTICS:" % name
	sceneName = name
