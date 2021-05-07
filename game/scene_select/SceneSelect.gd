extends Control
"""
Main view for selecting a scene to start
"""
const SceneCellScn = preload("res://scene_select/SceneCell.tscn")


export(int) var minNumberScenes: int = 12


onready var cellsGrid: GridContainer = $Panel/MarginContainer/SceneCells

var scenesData: Array = []


func _ready():
	_clearRefSizeCells()
	scenesData = _buildAvailableScenesData()
	for spec in scenesData:
		var sceneCell = SceneCellScn.instance()
		sceneCell.setData(spec)
		cellsGrid.add_child(sceneCell)
		Utils.tryConnect(sceneCell, "sceneSelected", self, "_onSceneCellSceneSelected")
	
	for emptyIdx in range(minNumberScenes - scenesData.size()):
		var placeholder = ReferenceRect.new()
		placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
		placeholder.size_flags_vertical = SIZE_EXPAND_FILL
		cellsGrid.add_child(placeholder)
	
	
func _buildAvailableScenesData() -> Array:
	return [
		Mock.sceneShiledShips(1)
	]
	
	
func _clearRefSizeCells():
	for child in cellsGrid.get_children():
		child.queue_free()


func _onSceneCellSceneSelected(sceneSpec: SceneSpec):
	var SpaceSceneScn: PackedScene = load("res://SpaceScene.tscn")
	var spaceScene = SpaceSceneScn.instance()
	spaceScene.setInitialSceneSpec(sceneSpec)
	get_tree().get_root().add_child(spaceScene)
	queue_free()
