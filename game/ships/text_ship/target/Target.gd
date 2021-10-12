extends Node2D

const PULSE_REDUCE_PER_SECOND = 0.5


onready var sprite: Sprite = $Sprite
onready var anim: AnimationPlayer = $Sprite/AnimationPlayer
onready var tween: Tween = $Sprite/Tween


func _ready():
	sprite.visible = false

	
func lockin():
	#sets sprite visible
	anim.play("lock-in")
	
	
func lockout():
	#sets sprite invisible
	anim.play("lock-out")
	
	
func pulse():
	#ignore pulsing when not spin animation
	if (anim.current_animation != "spin"):
		return
	sprite.scale *= 1.1
	if (tween.is_active()):
		tween.stop_all()
		tween.remove_all()
	_buildCurrentPulseReduceTween()
	tween.start()
	
	
func _buildCurrentPulseReduceTween():
	var scaleDelta = sprite.scale.x - 1.0
	tween.interpolate_property(
		sprite, "scale", 
		null, Vector2.ONE,
		scaleDelta / PULSE_REDUCE_PER_SECOND, 
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
