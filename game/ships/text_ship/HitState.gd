extends AnimationState
class_name HitState
"""
State of text ship getting hit
Playes an animation and reduces label charactersby number of them hit
"""

func enterState(prevState: String):
	.enterState(prevState)
	entity.hitCharacter(fsm.hitChars)
	entity.emit_signal("shipHit", entity.currentText.length())
