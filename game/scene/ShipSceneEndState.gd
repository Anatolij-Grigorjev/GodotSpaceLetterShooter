extends State
class_name ShipSceneEndState
"""
State actions for finishing a scene, with either victory or failure
"""
signal sceneCleared(sceneSpecId)
signal sceneFailed(sceneSpecId)


func _ready():
	Utils.tryConnect(self, "sceneCleared", Scenes, "_onSceneCleared")
	Utils.tryConnect(self, "sceneFailed", Scenes, "_onSceneFailed")


func enterState(prevState: String):
	.enterState(prevState)
	GameConfig.totalShooterScore += entity.totalScore.totalScore
	if (fsm.shooterFailed):
		emit_signal("sceneFailed", fsm.sceneSpecification.id)
	else:
		emit_signal("sceneCleared", fsm.sceneSpecification.id)
