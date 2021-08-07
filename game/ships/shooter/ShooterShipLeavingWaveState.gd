extends AnimationState
class_name ShooterShipLeavingWaveState
"""
Shooter ship leaving a wave
"""
const ROTATE_DEGREES_PER_SEC = 60


func enterState(prevState: String):
	entity.emptyChamber()
	yield(_resetRotationTween(), "completed")
	.enterState(prevState)
	
	
func _resetRotationTween():
	var currentScene = Scenes.activeScene
	var neutralSceneDirectionAngle = currentScene.directionShipAngles[currentScene.shipDirection]
	entity.tween.interpolate_property(
		entity, "rotation_degrees", 
		null, neutralSceneDirectionAngle, abs(entity.rotation) / ROTATE_DEGREES_PER_SEC, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	entity.tween.start()
	yield(entity.tween, "tween_all_completed")
	entity.tween.remove_all()
