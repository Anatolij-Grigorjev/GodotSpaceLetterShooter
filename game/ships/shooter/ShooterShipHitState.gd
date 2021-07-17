extends AnimationState
class_name ShooterShipHitState
"""
Hit state of shooter ship
Finishes when hit animation completes
"""

var hitShot

func enterState(prevState: String):
	.enterState(prevState)
	entity.emit_signal("shooterHitByShot", hitShot)
	entity.emptyChamber()
