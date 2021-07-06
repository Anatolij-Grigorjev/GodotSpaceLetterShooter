extends State
class_name ShipSceneStartState
"""
State behavior describing actions for a scene to startup 
and leading up to first wave
"""


func enterState(prevState: String):
	.enterState(prevState)
	
	assert(fsm.sceneSpecification)
	
	Utils.tryConnect(entity, "sceneCleared", Scenes, "_onSceneCleared")
	Utils.tryConnect(entity, "sceneFailed", Scenes, "_onSceneFailed")
	
	Utils.tryConnect(entity, "letterTyped", entity.playerInput, "addTypedLetter")
	Utils.tryConnect(entity, "letterTyped", entity.shooter, "chamberLetter")
	Utils.tryConnect(entity, "letterTyped", entity.shooter, "addSpoke")
	
	Utils.tryConnect(entity.shooter, "shotFired", fsm, "_onShipShotFired")
	Utils.tryConnect(entity.shooter, "chamberEmptied", entity.playerInput, "clearText")
	Utils.tryConnect(entity.shooter, "chamberEmptied", entity, "_onShooterClearChamber")
	Utils.tryConnect(entity.shooter, "hyperspeedToggled", entity, "_onShooterToggleHyperspeed")
	Utils.tryConnect(entity.shooter, "shooterHitByShot", entity, "_onShooterHitByShot")
