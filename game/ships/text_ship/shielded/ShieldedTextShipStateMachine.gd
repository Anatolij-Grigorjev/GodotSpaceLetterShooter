extends TextShipStateMachine
class_name ShieldedTextShipStateMachine
"""
additional text ship FSM actions and logic for shield useage
"""

func _ready():
	Utils.tryConnect(entity.get_node("Sprite/ShipBubble"), "bubbleBurst", self, "_onEntityBubbleBurst")


func _getNextState(delta: float) -> String:
	var nextGenericState := ._getNextState(delta)
	if (nextGenericState != NO_STATE_MATCHED):
		return nextGenericState
	match(state):
		"IdlingBubble":
			if lastCollidedShipCell.present():
				return _getShipAttemptedCollisionState(lastCollidedShipCell.readAndReset())
			if shipReachedFinishCell.present():
				return _getShipReachedFinishState()
				
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
