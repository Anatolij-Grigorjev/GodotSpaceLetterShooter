extends State
class_name AnimationState
"""
A kind of state that lasts for the duration of an animation
and finishes when that animation is completed
"""
export(NodePath) var animatorPath: NodePath
export(String) var animationName: String
export(bool) var playBackwards: bool = false

onready var animator: AnimationPlayer = get_node(animatorPath) as AnimationPlayer
var animationFinished: bool = false


func _ready():
	Utils.tryConnect(animator, "animation_finished", self, "_animatorFinishedAnimation")
	

func enterState(prevState: String):
	.enterState(prevState)
	animationFinished = false
	if (not playBackwards):
		animator.play(animationName)
	else:
		animator.play_backwards(animationName)
	
	
func exitState(nextState: String):
	.exitState(nextState)
	animationFinished = false
	
	
func _animatorFinishedAnimation(animationName: String) -> void:
	#only set flag if this animation finished during this state run
	animationFinished = isActive and animationName == self.animationName
