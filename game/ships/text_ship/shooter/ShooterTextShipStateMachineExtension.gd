extends TextShipStateMachineExtension
class_name ShooterTextShipStateMachineExtension
"""
additional text ship FSM actions and logic for shooting useage
"""


func initExtension():
	Utils.tryConnect(ownerFSM.getState("IdlingShoot"), "shotLettersDepleted", self, "_onEntityNotEnoughShotLetters")
	
	
func tryProcessCurrentState(state: String, delta: float) -> String:

	match(state):
		"IdlingShoot":
			var collisionState = ownerFSM._getLatestAnyCollisionState()
			if (collisionState != NO_STATE):
				return collisionState
				
			var idlingShootState = ownerFSM.getState(state)
			if (idlingShootState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		_:
			return NO_STATE_MATCHED
			
			
func _onEntityNotEnoughShotLetters(lettersLeft: int):
	ownerFSM.idlingActionsWeights.disableItem("IdlingShoot")
