extends TextShipStateMachine
class_name ShooterTextShipStateMachine
"""
additional text ship FSM actions and logic for shooting useage
"""
export(float) var shootingCooldown: float = 3.5
onready var shootingCooldownTween: Tween = $ShootingCooldown


func _ready():
	Utils.tryConnect(getState("IdlingShoot"), "shotLettersDepleted", self, "_onEntityNotEnoughShotLetters")
	Utils.tryConnect(entity, "shipHit", self, "_onTextShipHit")
	
	
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
			
			
func _onEntityNotEnoughShotLetters(lettersLeft: int):
	_disableShootingBehavior()
	

func _onTextShipHit(lettersRemaining: int):
	if lettersRemaining <= getState("IdlingShoot").maxShotLettersLength:
		_disableShootingBehavior()
		
		
func _disableShootingBehavior():
	idlingActionsWeights.disableItem("IdlingShoot")
	
	
func _exitState(prevState: String, nextState: String):
	if prevState == "IdlingShoot":
		_setNoseCooldownTween()
		shootingCooldownTween.start()
	._exitState(prevState, nextState)
	
	
func _getNextIdlingState() -> String:
	if shootingCooldownTween.is_active():
		return "Idling"
	else:
		return ._getNextIdlingState()
		
		
func _setNoseCooldownTween():
	shootingCooldownTween.remove_all()
	shootingCooldownTween.interpolate_property(
		entity.sprite.get_node('Nose'), 'self_modulate', 
		Color.red, Color.white, 
		shootingCooldown, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
