extends Node

var shooterShip: Node2D
var currentScene: Node2D setget setCurrentScene

var currentSceneStats: SceneStatsData

func _ready():
	pass


func setCurrentScene(scene: Node2D):
	if (scene != currentScene):
		currentScene = scene
		currentSceneStats = SceneStatsData.new(scene.sceneName)
