extends Control
"""
Script used to populate info fields on scene selection cell
using a SceneSpec
"""


onready var sceneTitle: Label = $Panel/OuterMargin/VBoxContainer/SceneTitle
onready var panel = $Panel

# ship types
onready var fastShipsRow = $Panel/OuterMargin/VBoxContainer/ShipRowsContainer/FastShipsRow
onready var shieldShipsRow = $Panel/OuterMargin/VBoxContainer/ShipRowsContainer/ShiledShipsRow
onready var shooterShipsRow = $Panel/OuterMargin/VBoxContainer/ShipRowsContainer/ShooterShipsRow


func _ready():
	pass


func setData(sceneSpec: SceneSpec):
	sceneTitle.text = "%s\nWaves: %s - %s ship(-s)" % [
		sceneSpec.sceneName,
		sceneSpec.smallestShipsWave,
		sceneSpec.largestShipsWave
	]
	panel.self_modulate = sceneSpec.sceneBgColor
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
