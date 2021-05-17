extends Node2D
"""
Global data related to loading scenes and tracking their progress
"""

export(Array, String) var sceneSpecPaths: Array = []

var loadedSceneSpecs: Array = []

var sceneCompleteTracking: Dictionary = {}


func _ready():
	loadedSceneSpecs = _loadSceneSpecs()
	#mark all scenes unfinished
	for spec in loadedSceneSpecs:
		sceneCompleteTracking[spec.id] = false
		
		
func _loadSceneSpecs() -> Array:
	var loadedScenes := [
		Mock.sceneShiledShips(1),
		Mock.sceneShipTypeQuantities(1)
	]
	for path in sceneSpecPaths:
		var sceneJSON = Utils.file2JSON(path)
		loadedScenes.append(Utils.parseJSONSceneSpec(sceneJSON))
	return loadedScenes
	
	
func _onSceneCleared(sceneSpecId: int):
	sceneCompleteTracking[sceneSpecId] = true
	_switchToSceneSelect()
	
	
func _switchToSceneSelect():
	var SceneSelectScn: PackedScene = load("res://scene_select/SceneSelect.tscn")
	var sceneSelectView = SceneSelectScn.instance()
	get_tree().get_root().add_child(sceneSelectView)
	queue_free()
