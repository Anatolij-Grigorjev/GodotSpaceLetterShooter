tool
extends Control

signal statsViewKeyPressed



export(String) var sceneName: String = "<SCENE NAME>" setget setSceneName


func _ready():
	set_process(false)
	yield($AnimationPlayer, "animation_finished")
	set_process(true)


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


func _process(delta: float):
	if (Input.is_action_just_released("ui_accept")):
		emit_signal("statsViewKeyPressed")
