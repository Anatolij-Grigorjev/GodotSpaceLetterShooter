extends State
class_name AnimationState
"""
A kind of state that lasts for the duration of an animation
and finishes when that animation is completed
"""
export(NodePath) var animatorPath: NodePath
export(String) var animationName: String


var animator: AnimationPlayer = get_node(animatorPath) as AnimationPlayer
var animationFinished: bool = false


func _ready():
	animator.connect("animation_finished", self, "_animatorFinishedAnimation")


func processState(delta: float):
	pass
	
	
func enterState(prevState: String):
	pass
	
	
func exitState(nextState: String):
	pass

	
func _animatorFinishedAnimation(animationName: String) -> void:
	animationFinished = animationName == self.animationName
