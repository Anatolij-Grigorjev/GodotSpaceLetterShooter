extends TextShipStateMachineExtension
class_name ShieldedTextShipStateMachineExtension
"""
additional text ship FSM actions and logic for shield useage
"""

func initExtension():
	Utils.tryConnect(ownerFSM.entity.get_node("Sprite/ShipBubble"), "bubbleBurst", self, "_onEntityBubbleBurst")


func tryProcessCurrentState(state: String, delta: float) -> String:
	
	match(state):
		"IdlingBubble":
			var collisionState = ownerFSM._getNextNonProjectileCollisionsState()
			if (collisionState != NO_STATE):
				return collisionState
				
			var idlingBubbleState = ownerFSM.getState(state)
			if (idlingBubbleState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		_:
			return NO_STATE_MATCHED


func _onEntityBubbleBurst():
	ownerFSM.entity.shipHasShield = false
	ownerFSM.idlingActionsWeights.disableItem("IdlingBubble")
	if ownerFSM.idlingActionsWeights.isItemDisabled("Idling"):
		ownerFSM.idlingActionsWeights.setItemWeight("Idling", 1)
