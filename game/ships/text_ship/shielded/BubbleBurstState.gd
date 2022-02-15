extends State
class_name BubbleBurstState
"""
Recovery state for textship when the shield is destroyed
ignores hitboxes, waits recovery animation, disabled shield idling
 and enabled the basic idling state
"""
export(float) var bubbleBurstTime = 0.55
	

func enterState(prevState: String):
	.enterState(prevState)
	entity.shipHasShield = false
	entity.anim.play("noshield_spooked")
	fsm.idlingActionsWeights.disableItem("IdlingBubble")
	fsm.idlingActionsWeights.setItemWeight("Idling", 1)

