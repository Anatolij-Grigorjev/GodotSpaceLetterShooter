extends Node2D
"""
Global data related to loading scenes and tracking their progress
"""

export(Array, String) var sceneSpecPaths: Array = []

var loadedSceneSpecs: Array = []

var sceneCompleteTracking: Dictionary = {}


var activeScene: Object


func _ready():
	loadedSceneSpecs = _loadSceneSpecs()
	#mark all scenes unfinished
	for spec in loadedSceneSpecs:
		sceneCompleteTracking[spec.id] = false
		
		
func _loadSceneSpecs() -> Array:
	var loadedScenes := [
		Mock.sceneShipTypeQuantities(1)
	]
	for path in sceneSpecPaths:
		var sceneJSON = Utils.file2JSON(path)
		loadedScenes.append(Utils.parseJSONSceneSpec(sceneJSON))
	return loadedScenes
	
	
func _onSceneCleared(sceneSpecId: int):
	sceneCompleteTracking[sceneSpecId] = true
	_switchToSceneSelect()
	

func _onSceneFailed(sceneSpecId: int):
	_switchToSceneSelect()
	
	
func _switchToSceneSelect():
	var SceneSelectScn: PackedScene = load("res://scene_select/SceneSelect.tscn")
	var sceneSelectView = SceneSelectScn.instance()
	get_tree().get_root().add_child(sceneSelectView)
	_replaceActiveScene(sceneSelectView)
	
	
func switchToShipScene(scenePath: String, sceneSpec: SceneSpec):
	var ShipScenScn: PackedScene = load(scenePath)
	var shipScene = ShipScenScn.instance()
	shipScene.setSceneSpecificaion(sceneSpec)
	get_tree().get_root().add_child(shipScene)
	_replaceActiveScene(shipScene)
	
	
func _replaceActiveScene(newActiveScene: Object):
	if (activeScene):
		activeScene.queue_free()
	activeScene = newActiveScene
