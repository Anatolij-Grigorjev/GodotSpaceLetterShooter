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
		_connectSceneStatsSignals()
		

func _connectSceneStatsSignals():
	#scene
	_connectSceneNodeStatsSignals(currentScene)
	#shooter
	var shooter: Node2D = get_tree().get_nodes_in_group("shooter")[0]
	_connectShooterStatsSignals(shooter)
	
	
func connectTextShipStatsSignals(textShip: TextShip):
	Utils.tryConnect(textShip, "textShipDestroyed", self, "_on_textShipShotDown")
	Utils.tryConnect(textShip.bubble, "bubbleBurst", self, "_on_textShipBubbleBurst")
	

func connectProjectileStatsSignals(projectile: Node2D):
	Utils.tryConnect(projectile, "projectileDestroyed", self, "_on_projectileDestroyed")
	
	
	
func _connectSceneNodeStatsSignals(scene: Node2D):
	Utils.tryConnect(scene, "letterTyped", self, "_on_playerLetterTyped")
	
	
func _connectShooterStatsSignals(shooter: Node2D):
	Utils.tryConnect(shooter, "shotFired", self, "_on_shooterShotFired")
	
	
	
func _on_playerLetterTyped(letter: String):
	currentSceneStats.totalLettersTyped += 1
	
func _on_shooterShotFired(shotWord: String):
	currentSceneStats.totalShotsFired += 1
	
func _on_textShipShotDown(text: String):
	currentSceneStats.shipsShot += 1
	currentSceneStats.totalShipsLetters += text.length()
	if (text.length() > currentSceneStats.longestShipWord.length()):
		currentSceneStats.longestShipWord = text
		
func _on_textShipBubbleBurst():
	currentSceneStats.shieldsBroken += 1
	
func _on_projectileDestroyed(text: String):
	currentSceneStats.projectilesShot += 1
