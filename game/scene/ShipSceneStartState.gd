extends State
"""
State behavior describing actions for a scene to startup 
and leading up to first wave
"""

var shipsBuilderThread: Thread


func enterState(prevState: String):
	.enterState(prevState)
	randomize()
	Stats.currentScene = entity
	shipsBuilderThread = Thread.new()
	Utils.tryConnect(entity, "sceneCleared", Scenes, "_onSceneCleared")
	Utils.tryConnect(entity, "sceneFailed", Scenes, "_onSceneFailed")
	
	Utils.tryConnect(entity, "letterTyped", entity.playerInput, "addTypedLetter")
	Utils.tryConnect(entity, "letterTyped", entity.shooter, "chamberLetter")
	
	Utils.tryConnect(entity.shooter, "shotFired", entity, "_onShipShotFired")
	Utils.tryConnect(entity.shooter, "chamberEmptied", entity.playerInput, "clearText")
