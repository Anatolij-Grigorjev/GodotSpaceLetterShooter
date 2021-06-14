extends AnimationState
class_name HitState
"""
State of text ship getting hit
Playes an animation and reduces label characters by 1
"""

func enterState(prevState: String):
	.enterState(prevState)
	entity.hitCharacter(fsm.hitChars)
	entity.emit_signal("shipHit", entity)
