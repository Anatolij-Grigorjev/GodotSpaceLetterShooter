extends CanvasLayer
"""
Global data related to loading scenes and tracking their progress
"""

export(Array, String) var sceneSpecPaths: Array = []

var loadedSceneSpecs: Array = []

var sceneCompleteTracking: Dictionary = {}

onready var anim = $AnimationPlayer


var activeScene: Object


func _ready():
	loadedSceneSpecs = _loadSceneSpecs()
	#mark all scenes unfinished
	for spec in loadedSceneSpecs:
		sceneCompleteTracking[spec.id] = false
	call_deferred("_setFirstActiveScene")
		
		
func _loadSceneSpecs() -> Array:
	var loadedScenes := [
		Mock.sceneShipTypeQuantities(0, 0, 1)
	]
	for path in sceneSpecPaths:
		var sceneJSON = Utils.file2JSON(path)
		loadedScenes.append(Utils.parseJSONSceneSpec(sceneJSON))
	return loadedScenes
	
	
func _setFirstActiveScene():
	if is_instance_valid(activeScene):
		return
	
	for activeNode in get_tree().get_root().get_children():
		if activeNode.is_in_group("scenes"):
			activeScene = activeNode
	
	
func _onSceneCleared(sceneSpecId: int):
	sceneCompleteTracking[sceneSpecId] = true
	_switchToSceneSelect()
	

func _onSceneFailed(sceneSpecId: int):
	_switchToSceneSelect()
	
	
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
