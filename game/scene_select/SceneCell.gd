tool
extends Panel
"""
Script used to populate info fields on scene selection cell
using a SceneSpec
"""
signal sceneSelected(spec)

const CURSOR_SCENE_SELECTED = preload("res://white_rect.png")


export(bool) var sceneDone: bool = false setget markSceneDone
export(String) var sceneCorpusSource: String = "corpus_path.txt" setget setCorpusPath


onready var anim: AnimationPlayer = $AnimationPlayer
onready var sceneTitle: Label = $OuterMargin/VBoxContainer/SceneTitle


# ship types
onready var fastShipsRow = $OuterMargin/VBoxContainer/ShipRowsContainer/FastShipsRow
onready var shieldShipsRow = $OuterMargin/VBoxContainer/ShipRowsContainer/ShiledShipsRow
onready var shooterShipsRow = $OuterMargin/VBoxContainer/ShipRowsContainer/ShooterShipsRow

var sceneHovered: bool = false
var sceneSpec: SceneSpec


func _ready():
	sceneHovered = false
	self.set("custom_styles/panel", self.get("custom_styles/panel").duplicate(true))
	#center pivot for scale animations
	rect_pivot_offset = rect_size / 2
	Utils.tryConnect($TouchPanel, "mouse_entered", self, "_onMouseEnteredArea")
	Utils.tryConnect($TouchPanel, "mouse_exited", self, "_onMouseExitedArea")
	
	
func markSceneDone(done: bool):
	sceneDone = done
	if ($OuterMargin/VBoxContainer/SceneTitle/SceneDoneMarker):
		$OuterMargin/VBoxContainer/SceneTitle/SceneDoneMarker.visible = done
	if ($LevelDoneOutline):
		$LevelDoneOutline.visible = done
	if ($OuterMargin/VBoxContainer/CorpusTextContainer):
		$OuterMargin/VBoxContainer/CorpusTextContainer.modulate = Color.black if done else Color.white
		
		
func setCorpusPath(path: String):
	if (not Utils.isEmptyString(path)):
		sceneCorpusSource = path
	else:
		sceneCorpusSource = GameConfig.DEFAULT_WORDS_CORPUS_PATH
	if ($OuterMargin/VBoxContainer/CorpusTextContainer/CorpusPathValueLbl):
		$OuterMargin/VBoxContainer/CorpusTextContainer/CorpusPathValueLbl.text = "'%s'" % sceneCorpusSource
	
	
func _process(delta):
	if (not sceneHovered):
		return
	if (Input.is_action_just_pressed("ui_accept")):
		_selectThisScene()
	


func setData(sceneSpec: SceneSpec):
	self.sceneSpec = sceneSpec
	$OuterMargin/VBoxContainer/SceneTitle.text = "%s\nWaves: %s - %s ship(-s)" % [
		sceneSpec.sceneName,
		sceneSpec.smallestShipsWave,
		sceneSpec.largestShipsWave
	]
	setCorpusPath(sceneSpec.wordsCorpusPath)
	self_modulate = sceneSpec.sceneBgColor
	var categorizedTypeCountsByRowNode = _categorizeAllowedShipTypes(sceneSpec.allowedShipsTypes)
	for rowNode in categorizedTypeCountsByRowNode:
		rowNode.get_node("Qnty").text = str(categorizedTypeCountsByRowNode[rowNode])
	
	
func _categorizeAllowedShipTypes(allowedShipTypes: Dictionary) -> Dictionary:
	var fastShips: int = 0
	var shieldShips: int = 0
	var shootShips: int = 0
	
	for key in allowedShipTypes:
		var shipType := key as SceneShipLimits
		if shipType.shootInclination > 0:
			shootShips += allowedShipTypes[shipType]
		elif shipType.shieldHitPoints > 0:
			shieldShips += allowedShipTypes[shipType]
		else:
			fastShips += allowedShipTypes[shipType]
	
	return {
		$OuterMargin/VBoxContainer/ShipRowsContainer/FastShipsRow: fastShips,
		$OuterMargin/VBoxContainer/ShipRowsContainer/ShiledShipsRow: shieldShips,
		$OuterMargin/VBoxContainer/ShipRowsContainer/ShooterShipsRow: shootShips
	}
	

func _onMouseEnteredArea():
	if (Utils.animIsPlayingAnimation(anim, "select")):
		return
	anim.play("hover")
	sceneHovered = true
	Input.set_custom_mouse_cursor(CURSOR_SCENE_SELECTED)
	
	
func _onMouseExitedArea():
	if (Utils.animIsPlayingAnimation(anim, "select")):
		return
	anim.play("leave")
	sceneHovered = false
	Input.set_custom_mouse_cursor(null)
	
	
	
func _selectThisScene():
	anim.play("select")
	yield(anim, "animation_finished")
	Input.set_custom_mouse_cursor(null)
	emit_signal("sceneSelected", sceneSpec)
	set_process(false)
