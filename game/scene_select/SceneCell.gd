extends Panel
"""
Script used to populate info fields on scene selection cell
using a SceneSpec
"""

onready var anim: AnimationPlayer = $AnimationPlayer
onready var area: Area2D = $Area2D
onready var sceneTitle: Label = $OuterMargin/VBoxContainer/SceneTitle


# ship types
onready var fastShipsRow = $OuterMargin/VBoxContainer/ShipRowsContainer/FastShipsRow
onready var shieldShipsRow = $OuterMargin/VBoxContainer/ShipRowsContainer/ShiledShipsRow
onready var shooterShipsRow = $OuterMargin/VBoxContainer/ShipRowsContainer/ShooterShipsRow


func _ready():
	var cellSize = rect_size
	area.position = Vector2.ZERO
	var areaCollider: CollisionShape2D = area.get_child(0)
	areaCollider.shape = RectangleShape2D.new()
	areaCollider.shape.extents = cellSize / 2
	area.connect("mouse_entered", self, "_onMouseEnteredArea")
	area.connect("mouse_exited", self, "_onMouseExitedArea")
	


func setData(sceneSpec: SceneSpec):
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
	
	
func _onMouseExitedArea():
	anim.play("leave")
