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
		sceneCell.sceneDone = Scenes.scenesStateTracking[spec.id].complete
		sceneCell.sceneLocked = not Scenes.scenesStateTracking[spec.id].unlocked
		cellsGrid.add_child(sceneCell)
		Utils.tryConnect(sceneCell, "sceneSelected", self, "_onSceneCellSceneSelected")
	
	for emptyIdx in range(minNumberScenes - Scenes.loadedSceneSpecs.size()):
		var placeholder = ReferenceRect.new()
		placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
		placeholder.size_flags_vertical = SIZE_EXPAND_FILL
		cellsGrid.add_child(placeholder)
	
	call_deferred("_unlockNewSceneCells")
	
	
func _clearRefSizeCells():
	for child in cellsGrid.get_children():
		child.queue_free()


func _onSceneCellSceneSelected(sceneSpec: SceneSpec):
	Scenes.switchToShipScene(sceneTypeLoadPaths[sceneSpec.type], sceneSpec)
	
	
func _unlockNewSceneCells():
	var cellsToUnlock: Array = _findSceneCellsWithSpecIds(Scenes.newlyUnlockedScenesIds)
	Scenes.newlyUnlockedScenesIds.clear()
	if cellsToUnlock.empty():
		return
	yield(get_tree().create_timer(0.5), "timeout")
	var newScenesAnim = $ScenesUnlockedPanel/AnimationPlayer
	newScenesAnim.play("new_scenes")
	yield(newScenesAnim, "animation_finished")
	cellsToUnlock.sort_custom(self, "_sceneCellsByPointsRequirementSort")
	yield(get_tree().create_timer(0.25), "timeout")
	for sceneCell in cellsToUnlock:
		var cellLock = sceneCell.get_node("SceneLock")
		yield(cellLock.playUnlockSequence(), "completed")
		Scenes.scenesStateTracking[sceneCell.sceneSpec.id].unlocked = true
		sceneCell.sceneLocked = false
		yield(get_tree().create_timer(0.25), "timeout")
	
	
func _findSceneCellsWithSpecIds(specIds: Array) -> Array:
	var foundCells = []
	for sceneCell in cellsGrid.get_children():
		if ("sceneSpec" in sceneCell and sceneCell.sceneSpec.id in specIds):
			foundCells.append(sceneCell)
	return foundCells
	
	
func _sceneCellsByPointsRequirementSort(sceneCell1: Control, sceneCell2: Control) -> bool:
	if sceneCell1.sceneSpec.unlockPoints < sceneCell2.sceneSpec.unlockPoints:
		return true
	else:
		return false
	
