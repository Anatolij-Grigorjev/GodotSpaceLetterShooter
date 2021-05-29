extends State
class_name ShipSceneEndState
"""
State actions for finishing a scene, with either victory or failure
"""


func enterState(prevState: String):
	.enterState(prevState)
	if (fsm.shooterFailed):
		entity.emit_signal("sceneFailed", fsm.sceneSpecification.id)
	else:
		entity.emit_signal("sceneCleared", fsm.sceneSpecification.id)
