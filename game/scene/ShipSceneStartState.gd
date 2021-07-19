extends State
class_name ShipSceneStartState
"""
State behavior describing actions for a scene to startup 
and leading up to first wave
"""


func enterState(prevState: String):
	.enterState(prevState)
	
	assert(fsm.sceneSpecification)
	
	Utils.tryConnect(entity, "letterTyped", entity.playerInput, "addTypedLetter")
	Utils.tryConnect(entity, "letterTyped", entity.shooter.fsm.getState('Preparing'), "letterTyped")
	Utils.tryConnect(entity, "fireCodeTyped", entity.shooter.fsm, "sceneFireCodeTyped")
