extends Node
"""
Connections relted to gather statistical data bout things happening
in the current scene
"""


var currentScene: Node2D setget setCurrentScene

var currentSceneStats: SceneStatsData

func _ready():
	pass


func setCurrentScene(scene: Node2D):
	if (scene != currentScene):
		currentScene = scene
		currentSceneStats = SceneStatsData.new(scene.fsm.sceneSpecification.sceneName)
		_connectSceneStatsSignals()
		

func _connectSceneStatsSignals():
	#scene
	_connectSceneNodeStatsSignals(currentScene)
	#shooter
	var shooter: Node2D = Utils.getFirstTreeNodeInGroup(get_tree(), "shooter")
	_connectShooterStatsSignals(shooter)
	
	
func connectTextShipStatsSignals(textShip: TextShip):
	Utils.tryConnect(textShip, "textShipDestroyed", self, "_onTextShipShotDown")
	if is_instance_valid(textShip.get_node("Sprite/ShipBubble")):
		Utils.tryConnect(textShip.get_node("Sprite/ShipBubble"), "bubbleBurst", self, "_onTextShipBubbleBurst")
	Utils.tryConnect(textShip, "shotFired", self, "_onTextShipShotFired")
	Utils.tryConnect(textShip, "shipDroppedLetter", self, "_onTextShipDroppedLetter")
	Utils.tryConnect(textShip, "shipPickedUpText", self, "_onTextShipPickedUpText")
	

func connectProjectileStatsSignals(projectile: Node2D):
	Utils.tryConnect(projectile, "projectileDestroyed", self, "_onProjectileDestroyed")
	Utils.tryConnect(projectile, "projectileMissed", self, "_onProjectileMissed")
	
	
func _connectSceneNodeStatsSignals(scene: Node2D):
	Utils.tryConnect(scene, "letterTyped", self, "_onPlayerLetterTyped")
	
	
func _connectShooterStatsSignals(shooter: Node2D):
	Utils.tryConnect(shooter, "shotFired", self, "_onShooterShotFired")
	
	
	
func _onPlayerLetterTyped(letter: String):
	currentSceneStats.totalLettersTyped += 1
	
func _onShooterShotFired(projectile):
	currentSceneStats.totalShotsFired += 1
	
func _onProjectileMissed():
	currentSceneStats.totalShotsMissed += 1
	
func _onTextShipShotFired(projectile: Node2D):
	currentSceneStats.totalProjectilesLetters += projectile.get_node("Label").text.length()
	
func _onTextShipShotDown(text: String):
	currentSceneStats.shipsShot += 1
	currentSceneStats.totalShipsLetters += text.length()
	if (text.length() > currentSceneStats.longestShipWord.length()):
		currentSceneStats.longestShipWord = text
		
func _onTextShipBubbleBurst():
	currentSceneStats.shieldsBroken += 1
	
func _onTextShipDroppedLetter(letterNode):
	currentSceneStats.totalProjectilesLetters += 1
	
func _onTextShipPickedUpText(currentText: String):
	currentSceneStats.totalProjectilesLetters -= 1
	
func _onProjectileDestroyed(text: String):
	currentSceneStats.projectilesShot += 1
