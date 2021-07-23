extends State
class_name AnimationState
"""
A kind of state that lasts for the duration of an animation
and finishes when that animation is completed
"""
export(NodePath) var animatorPath: NodePath
export(String) var animationName: String


onready var animator: AnimationPlayer = get_node(animatorPath) as AnimationPlayer
var animationFinished: bool = false


func _ready():
	Utils.tryConnect(animator, "animation_finished", self, "_animatorFinishedAnimation")
	

func enterState(prevState: String):
	.enterState(prevState)
	animationFinished = false
	animator.play(animationName)
	
	
func exitState(nextState: String):
	.exitState(nextState)
	animationFinished = false
	
	
func _animatorFinishedAnimation(animationName: String) -> void:
	animationFinished = animationName == self.animationName
