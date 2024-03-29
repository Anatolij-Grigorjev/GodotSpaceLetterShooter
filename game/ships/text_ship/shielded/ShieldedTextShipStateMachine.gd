extends TextShipStateMachine
class_name ShieldedTextShipStateMachine
"""
additional text ship FSM actions and logic for shield useage
"""


func _ready():
	Utils.tryConnect(entity.get_node("Sprite/ShipBubble"), "bubbleBurst", self, "_onEntityBubbleBurst")


func _getNextState(delta: float) -> String:
	var baseNextState := ._getNextState(delta)
	if baseNextState != NO_STATE:
		return baseNextState
		
	match(state):
		"IdlingBubble":
			var idlingBubbleState = getState(state)
			if (idlingBubbleState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		"BubbleBurst":
			var bubbleBurstState = getState(state)
			if bubbleBurstState.stateTime >= bubbleBurstState.bubbleBurstTime:
				return "Idling"
			else:
				return NO_STATE
		_:
			return NO_STATE


func _onEntityBubbleBurst():
	setState("BubbleBurst")
