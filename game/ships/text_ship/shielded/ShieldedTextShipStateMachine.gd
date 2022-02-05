extends TextShipStateMachine
class_name ShieldedTextShipStateMachine
"""
additional text ship FSM actions and logic for shield useage
"""
const ANY_POSITIVE_NUM = 5



func _ready():
	Utils.tryConnect(entity.get_node("Sprite/ShipBubble"), "bubbleBurst", self, "_onEntityBubbleBurst")
	Utils.tryConnect(entity.get_node("Sprite/ShipBubble"), "bubbleBurst", Scenes.activeScene, "_onTextShipHit", [ANY_POSITIVE_NUM])


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
		_:
			return NO_STATE


func _onEntityBubbleBurst():
	entity.shipHasShield = false
	entity.anim.play("noshield_spooked")
	yield(entity.anim, "animation_finished")
	idlingActionsWeights.disableItem("IdlingBubble")
	if idlingActionsWeights.isItemDisabled("Idling"):
		idlingActionsWeights.setItemWeight("Idling", 1)
