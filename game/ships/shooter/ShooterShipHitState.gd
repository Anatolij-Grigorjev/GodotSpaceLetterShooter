extends AnimationState
class_name ShooterShipHitState
"""
Hit state of shooter ship
Finishes when hit animation completes
"""

var hitShot

func enterState(prevState: String):
	.enterState(prevState)
	_hideShipShotFX()
	entity.bodyCollider().disabled = true
	entity.emptyChamber()
	entity.emit_signal("shooterHitByShot", hitShot)
	
	
func exitState(nextState: String):
	.exitState(nextState)
	entity.bodyCollider().disabled = false
	
	
	
func _hideShipShotFX():
	_removeShipSpokes()
	#hide shooting animation sprites
	entity.shotPosition.get_node('ShotSprite').visible = false
	
	
func _removeShipSpokes():
	for spokeNode in get_tree().get_nodes_in_group("spoke"):
		spokeNode.queue_free()
