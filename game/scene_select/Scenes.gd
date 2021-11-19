extends CanvasLayer
"""
Global data related to loading scenes and tracking their progress
"""

export(String) var sceneSpecsPath: String
export(Array, String) var excludePaths: Array = []

var loadedSceneSpecs: Dictionary = {}

var scenesStateTracking: Dictionary = {}

var newlyUnlockedScenesIds: Array = []

onready var anim = $AnimationPlayer


var activeScene: Object


func _ready():
	loadedSceneSpecs = _loadSceneSpecs()
	#mark all scenes unfinished
	for specId in loadedSceneSpecs:
		var spec: SceneSpec = loadedSceneSpecs[specId]
		scenesStateTracking[specId] = {
			"spec": spec,
			"complete": false,
			"unlocked": specId == "sample"
		}
	call_deferred("_unlockScenesIfPreReqComplete")
	call_deferred("_setFirstActiveScene")
		
		
func _loadSceneSpecs() -> Dictionary:
	var loadedScenes := []
	var foundScenesPaths = Utils.removeAllFrom(_getScenesFilePaths(), excludePaths)
	for path in foundScenesPaths:
		var sceneJSON = Utils.file2JSON(path)
		loadedScenes.append(Mapper.parseJSONSceneSpec(sceneJSON))
	loadedScenes.sort_custom(self, "_sortScenesByOrderAsc")
	return Utils.assocToProp(loadedScenes, "id")
	

func _getScenesFilePaths() -> Array:
	var filenames := Utils.getFilenamesInDirectory(sceneSpecsPath, ".json")
	var filePaths := []
	for filename in filenames:
		filePaths.append(Utils.combinePathParts(sceneSpecsPath, filename))
	return filePaths

	
	
func _setFirstActiveScene():
	if is_instance_valid(activeScene):
		return
	
	for activeNode in get_tree().get_root().get_children():
		if activeNode.is_in_group("scenes"):
			activeScene = activeNode
	
	
func _onSceneCleared(sceneSpecId: String):
	scenesStateTracking[sceneSpecId].complete = true
	_switchToSceneSelect()
	_unlockScenesIfPreReqComplete()
	

func _onSceneFailed(sceneSpecId: String):
	_switchToSceneSelect()
	_unlockScenesIfPreReqComplete()
	
	
func _switchToSceneSelect():
	yield(_fadeToBlackAndWait(), "completed")
	var SceneSelectScn: PackedScene = load("res://scene_select/SceneSelect.tscn")
	var sceneSelectView = SceneSelectScn.instance()
	get_tree().get_root().add_child(sceneSelectView)
	_replaceActiveScene(sceneSelectView)
	_unfadeBlack()
	
	
func switchToShipScene(scenePath: String, sceneSpec: SceneSpec):
	yield(_fadeToBlackAndWait(), "completed")
	var ShipScenScn: PackedScene = load(scenePath)
	var shipScene = ShipScenScn.instance()
	shipScene.setSceneSpecificaion(sceneSpec)
	get_tree().get_root().add_child(shipScene)
	_replaceActiveScene(shipScene)
	_unfadeBlack()
	
	
func _replaceActiveScene(newActiveScene: Object):
	if (activeScene):
		print("Replacing active scene %s with new scene: %s" % [activeScene, newActiveScene])
		if is_instance_valid(activeScene.get_parent()):
			var parent: Node = activeScene.get_parent()
			parent.remove_child(activeScene)
		activeScene.queue_free()
	activeScene = newActiveScene
	
	
func _fadeToBlackAndWait():
	anim.play("fade")
	yield(anim, "animation_finished")
	

func _unfadeBlack():
	anim.play_backwards("fade")
	
	
func _unlockScenesIfPreReqComplete():
	var lockedSceneSpecIds: Array = _findLockedSceneSpecIds()
	for specId in lockedSceneSpecIds:
		var spec: SceneSpec = scenesStateTracking[specId].spec
		if _allScenesWithIdsCompleted(spec.unlocksAfter):
			newlyUnlockedScenesIds.append(specId)
	if not newlyUnlockedScenesIds.empty():
		print("Unlocking %s more scenes!" % newlyUnlockedScenesIds.size())


func _findLockedSceneSpecIds() -> Array:
	var lockedSceneSpecIds = []
	for specId in scenesStateTracking:
		var sceneState = scenesStateTracking[specId]
		if not sceneState.unlocked:
			lockedSceneSpecIds.append(specId)
	return lockedSceneSpecIds
	

func _allScenesWithIdsCompleted(sceneIds: Array) -> bool:
	var allComplete := true
	for id in sceneIds:
		allComplete = allComplete and scenesStateTracking[id].complete
		if not allComplete:
			return false
	return allComplete
	

func _sortScenesByOrderAsc(scene1, scene2) -> bool:
	return scene1.order < scene2.order
