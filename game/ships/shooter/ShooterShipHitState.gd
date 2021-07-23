extends AnimationState
class_name ShooterShipHitState
"""
Hit state of shooter ship
Finishes when hit animation completes
"""

var hitShot

func enterState(prevState: String):
	.enterState(prevState)
	_removeShipSpokes()
	entity.emptyChamber()
	entity.emit_signal("shooterHitByShot", hitShot)
	
	
func _removeShipSpokes():
	for spokeNode in get_tree().get_nodes_in_group("spoke"):
		spokeNode.queue_free()
