extends TextShipStateMachine
class_name ShooterTextShipStateMachine
"""
additional text ship FSM actions and logic for shooting useage
"""
export(float) var shootingCooldown: float = 3.5
export(int) var maxShotLettersLength: int = 2

onready var cooldownBar = get_node("../CooldownBar")



func _ready():
	Utils.tryConnect(getState("IdlingShoot"), "textShipLettersShot", self, "_checkShipAllowedKeepShooting")
	Utils.tryConnect(entity, "shipHit", self, "_checkShipAllowedKeepShooting")
	Utils.tryConnect(entity, "shipPickedUpText", self, "_checkHasShootableText")
	cooldownBar.cooldownTime = shootingCooldown
	
	
func _getNextState(delta: float) -> String:
	var baseNextState := ._getNextState(delta)
	if baseNextState != NO_STATE:
		return baseNextState


	match(state):
		"IdlingShoot":
			var collisionState = _getNextNonProjectileCollisionsState()
			if (collisionState != NO_STATE):
				return collisionState
				
			var idlingShootState = getState(state)
			if (idlingShootState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		_:
			return NO_STATE
			
			
func _checkShipAllowedKeepShooting(lettersLeft: int):
	if lettersLeft <= maxShotLettersLength:
		_disableShootingBehavior()
		
		
func _disableShootingBehavior():
	idlingActionsWeights.disableItem("IdlingShoot")
	

func _enableShootingBehavior():
	idlingActionsWeights.setItemWeight("IdlingShoot", 1)
	
	
func _checkHasShootableText(currentText: String):
	if (
		currentText.length() > maxShotLettersLength 
		and idlingActionsWeights.isItemDisabled("IdlingShoot")
	):
		_enableShootingBehavior()
	
	
func _exitState(prevState: String, nextState: String):
	if prevState == "IdlingShoot":
		cooldownBar.startCooldown()
	._exitState(prevState, nextState)
	
	
func _getNextIdlingState() -> String:
	if cooldownBar.cooldownInProgress():
		return "Idling"
	else:
		return ._getNextIdlingState()
		
		
func _canShootAgain() -> bool:
	return maxShotLettersLength < entity.currentText.length()
