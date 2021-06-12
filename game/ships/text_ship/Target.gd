extends Sprite

func _ready():
	visible = false
	
	
func _process(delta: float):
	if (visible 
		and scale.x > 1.0 and scale.y > 1.0 
		and $AnimationPlayer.current_animation == "spin"
	):
		scale = lerp(scale, Vector2.ONE, delta * 0.0001)
		if (scale.x < 1.01 and scale.y < 1.01):
			scale = Vector2.ONE
	

	
func lockin():
	visible = true
	$AnimationPlayer.play("lock-in")
	
	
func lockout():
	$AnimationPlayer.play("lock-out")
	visible = false
	
	
func pulse():
	scale *= 1.25
