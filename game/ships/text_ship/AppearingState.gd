extends State
class_name Appearing
"""
Define text ship behavior while it is first appearing onscreen
"""

var shipAppearingTime: float = 1.0


func processState(delta: float):
	.processState(delta)
	
	
func enterState(prevState: String):
	.enterState(prevState)
	Animations.animPlayAnimationInTime(
		entity.anim, "appear", shipAppearingTime)
	_resetShipStartingValues()
	
	
	
func exitState(nextState: String):
	.exitState(nextState)
	
	
func _resetShipStartingValues():
	var sprite = entity.sprite as Sprite
	sprite.position = Vector2.ZERO
	sprite.rotation_degrees = 0
	sprite.modulate = Color.white
	sprite.material = ShaderMaterial.new()
	sprite.visible = true
	

