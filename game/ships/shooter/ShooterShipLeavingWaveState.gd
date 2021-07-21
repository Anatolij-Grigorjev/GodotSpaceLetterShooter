extends AnimationState
class_name ShooterShipLeavingWaveState
"""
Shooter ship leaving a wave
"""
const ROTATE_RADS_PER_SEC = 3


func enterState(prevState: String):
	yield(_resetRotationTween(), "completed")
	.enterState(prevState)
	
	
func _resetRotationTween():
	entity.tween.interpolate_property(
		entity, "rotation", 
		null, 0.0, abs(entity.rotation) / ROTATE_RADS_PER_SEC, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	entity.tween.start()
	yield(entity.tween, "tween_all_completed")
	entity.tween.remove_all()
