extends Control
"""
Main view for selecting a scene to start
"""
const SceneCellScn = preload("res://scene_select/SceneCell.tscn")


export(int) var minNumberScenes: int = 12
export(Dictionary) var sceneTypeLoadPaths: Dictionary = {
	"space": "res://scene/space_scene/SpaceScene.tscn",
	"hyperspace": "res://scene/space_scene/HyperSpaceScene.tscn"
}


onready var cellsGrid: GridContainer = $Panel/VBoxContainer/MarginContainer/SceneCells
onready var totalRunningScore: Control = $Panel/VBoxContainer/HBoxContainer/TotalRunningScore


func _ready():
	
	totalRunningScore.totalScore = GameConfig.totalShooterScore
	
	_clearRefSizeCells()
	
	for spec in Scenes.loadedSceneSpecs:
		var sceneCell = SceneCellScn.instance()
		sceneCell.setData(spec)
		sceneCell.sceneDone = Scenes.sceneCompleteTracking[spec.id]
		sceneCell.sceneLocked = not sceneCell.isUnlockedWithPointsTotal(GameConfig.totalShooterScore)
		cellsGrid.add_child(sceneCell)
		Utils.tryConnect(sceneCell, "sceneSelected", self, "_onSceneCellSceneSelected")
	
	for emptyIdx in range(minNumberScenes - Scenes.loadedSceneSpecs.size()):
		var placeholder = ReferenceRect.new()
		placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
		placeholder.size_flags_vertical = SIZE_EXPAND_FILL
		cellsGrid.add_child(placeholder)
	
	
func _clearRefSizeCells():
	for child in cellsGrid.get_children():
		child.queue_free()


func _onSceneCellSceneSelected(sceneSpec: SceneSpec):
	Scenes.switchToShipScene(sceneTypeLoadPaths[sceneSpec.type], sceneSpec)
