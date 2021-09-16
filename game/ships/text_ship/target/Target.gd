extends Sprite

const PULSE_REDUCE_PER_SECOND = 0.5


onready var anim: AnimationPlayer = $AnimationPlayer
onready var tween: Tween = $Tween


func _ready():
	visible = false

	
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
	scale *= 1.1
	if (tween.is_active()):
		tween.stop_all()
		tween.remove_all()
	_buildCurrentPulseReduceTween()
	tween.start()
	
	
func _buildCurrentPulseReduceTween():
	var scaleDelta = scale.x - 1.0
	tween.interpolate_property(
		self, "scale", 
		null, Vector2.ONE,
		scaleDelta / PULSE_REDUCE_PER_SECOND, 
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
