extends TextShipStateMachine
class_name ShooterTextShipStateMachine
"""
additional text ship FSM actions and logic for shooting useage
"""


func _ready():
	Utils.tryConnect(getState("IdlingShoot"), "shotLettersDepleted", self, "_onEntityNotEnoughShotLetters")
	
	
func _getNextState(delta: float) -> String:
	var nextGenericState := ._getNextState(delta)
	if (nextGenericState != NO_STATE_MATCHED):
		return nextGenericState
	match(state):
		"IdlingShoot":
			var collisionState = _getLatestAnyCollisionState()
			if (collisionState != NO_STATE):
				return collisionState
			var idlingShootState = getState(state)
			if (idlingShootState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		_:
			return NO_STATE_MATCHED
			
			
func _onEntityNotEnoughShotLetters(lettersLeft: int):
	idlingActionsWeights.disableItem("IdlingShoot")
