tool
extends Control

signal statsViewKeyPressed(view)



export(String) var sceneName: String = "<SCENE NAME>" setget setSceneName


func _ready():
	set_process(false)
	yield($AnimationPlayer, "animation_finished")
	set_process(true)


func setData(data: SceneStatsData):
	print(data)
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/LettersTypedValue.text = str(data.totalLettersTyped)
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/ShotsFiredValue.text = str(data.totalShotsFired)
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/ShotsMissedValue.text = str(data.totalShotsMissed)
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/ShieldsBrokenValue.text = str(data.shieldsBroken)
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/ShipsDestroyedValue.text = str(data.shipsShot)
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/ProjectilesDestroyedValue.text = str(data.projectilesShot)
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/TotalShipsLettersValue.text = "%s/%s" % [data.totalShipsLetters, (data.totalShipsLetters + data.totalProjectilesLetters)]
	$Panel/MarginFrame/VBoxContainer/TitleAndStats/GridContainer/LongestShipWordValue.text = data.longestShipWord
	

func setSceneName(name: String):
	if ($Panel/MarginFrame/VBoxContainer/TitleAndStats/Title):
		$Panel/MarginFrame/VBoxContainer/TitleAndStats/Title.text = "\"%s\" STATISTICS:" % name
	sceneName = name


func _process(delta: float):
	if (Input.is_action_just_released("ui_accept")):
		emit_signal("statsViewKeyPressed", self)
