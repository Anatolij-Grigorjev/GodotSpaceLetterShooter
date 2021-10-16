extends TextShipStateMachine
class_name ShieldedTextShipStateMachine
"""
additional text ship FSM actions and logic for shield useage
"""

func _ready():
	Utils.tryConnect(entity.get_node("Sprite/ShipBubble"), "bubbleBurst", self, "_onEntityBubbleBurst")


func _getNextState(delta: float) -> String:
	var baseNextState := ._getNextState(delta)
	if _stateDecided(baseNextState):
		return baseNextState
		
	match(state):
		"IdlingBubble":
			var collisionState = _getNextNonProjectileCollisionsState()
			if (collisionState != NO_STATE):
				return collisionState
				
			var idlingBubbleState = getState(state)
			if (idlingBubbleState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		_:
			return NO_STATE_MATCHED


func _onEntityBubbleBurst():
	entity.shipHasShield = false
	idlingActionsWeights.disableItem("IdlingBubble")
	if idlingActionsWeights.isItemDisabled("Idling"):
		idlingActionsWeights.setItemWeight("Idling", 1)
