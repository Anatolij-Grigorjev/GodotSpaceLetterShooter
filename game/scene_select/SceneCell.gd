extends Panel
"""
Script used to populate info fields on scene selection cell
using a SceneSpec
"""
signal sceneSelected(spec)

const CURSOR_SCENE_SELECTED = preload("res://white_rect.png")

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
	Utils.tryConnect($TouchPanel, "mouse_entered", self, "_onMouseEnteredArea")
	Utils.tryConnect($TouchPanel, "mouse_exited", self, "_onMouseExitedArea")
	
	
func _process(delta):
	if (not sceneHovered):
		return
	if (Input.is_action_just_pressed("ui_accept")):
		_selectThisScene()
	


func setData(sceneSpec: SceneSpec):
	self.sceneSpec = sceneSpec
	sceneTitle.text = "%s\nWaves: %s - %s ship(-s)" % [
		sceneSpec.sceneName,
		sceneSpec.smallestShipsWave,
		sceneSpec.largestShipsWave
	]
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
		fastShipsRow: fastShips,
		shieldShipsRow: shieldShips,
		shooterShipsRow: shootShips
	}
	

func _onMouseEnteredArea():
	anim.play("hover")
	sceneHovered = true
	Input.set_custom_mouse_cursor(CURSOR_SCENE_SELECTED)
	
	
	
func _onMouseExitedArea():
	anim.play("leave")
	sceneHovered = false
	Input.set_custom_mouse_cursor(null)
	
	
func _selectThisScene():
	anim.play("select")
	emit_signal("sceneSelected", sceneSpec)
	set_process(false)
