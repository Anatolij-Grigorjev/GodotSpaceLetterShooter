tool
extends Control

export(String) var sceneName: String = "<SCENE NAME>" setget setSceneName


func _ready():
#	setData(SceneStatsData.new("TEST-SCENE"))
	pass


func setData(data: SceneStatsData):
	print(data)
	$Panel/MarginFrame/TitleAndStats/GridContainer/LettersTypedValue.text = str(data.totalLettersTyped)
	$Panel/MarginFrame/TitleAndStats/GridContainer/ShotsFiredValue.text = str(data.totalShotsFired)
	$Panel/MarginFrame/TitleAndStats/GridContainer/ShotsMissedValue.text = str(data.totalShotsMissed)
	$Panel/MarginFrame/TitleAndStats/GridContainer/ShieldsBrokenValue.text = str(data.shieldsBroken)
	$Panel/MarginFrame/TitleAndStats/GridContainer/ShipsDestroyedValue.text = str(data.shipsShot)
	$Panel/MarginFrame/TitleAndStats/GridContainer/ProjectilesDestroyedValue.text = str(data.projectilesShot)
	$Panel/MarginFrame/TitleAndStats/GridContainer/TotalShipsLettersValue.text = "%s/%s" % [data.totalShipsLetters, (data.totalShipsLetters + data.totalProjectilesLetters)]
	$Panel/MarginFrame/TitleAndStats/GridContainer/LongestShipWordValue.text = data.longestShipWord
	

func setSceneName(name: String):
	if ($Panel/MarginFrame/TitleAndStats/Title):
		$Panel/MarginFrame/TitleAndStats/Title.text = "\"%s\" STATISTICS:" % name
	sceneName = name
