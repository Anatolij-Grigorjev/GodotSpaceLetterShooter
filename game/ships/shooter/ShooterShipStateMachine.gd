extends StateMachine
class_name ShooterShipStateMachine
"""
FSM for handling states of shooter ship
"""
export(Array, String) var noInterruptionStates = ["Hit"]
var requestedNextState: String = NO_STATE


func _ready():
	entity.emptyChamber()
	
	
func _getNextState(delta: float) -> String:
	
	if (requestedNextState != NO_STATE):
		var nextState = requestedNextState
		requestedNextState = NO_STATE
		if _shouldUseNextRequestedState(nextState, delta):
			return nextState
	
	match (state):
		"StartingFirstWave":
			return _ifAnimationFinishedGoToState("Preparing")
		"StartingNextWave":
			return _ifAnimationFinishedGoToState("Preparing")
		"Preparing":
			return NO_STATE
		"Shooting":
			var shootingState = getState(state)
			if (shootingState.shootingDone):
				return "Preparing"
			else:
				return NO_STATE
		"Hit":
			var animatedState: AnimationState = getState(state)
			if animatedState.animationFinished:
				_startInvincibility()
				return "Preparing"
			else:
				return NO_STATE
		"LeavingWave":
			return _ifAnimationFinishedGoToState("Leaving")
		"Leaving":
			
			return NO_STATE
		_: 
			breakpoint
			return NO_STATE
			
			
func _ifAnimationFinishedGoToState(nextState: String) -> String:
	var animatedState: AnimationState = getState(state)
	if animatedState.animationFinished:
		return nextState
	else:
		return NO_STATE
	
	
func onSceneFireCodeTyped(shootableTarget):
	getState('Shooting').shotTarget = shootableTarget
	requestNextState('Shooting')
	
	
	
func onSceneLetterTyped(letter: String):
	if (state == 'Preparing'):
		getState(state).letterTyped(letter)
	
		
	
func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (
		areaOwner.is_in_group('projectile') 
		and entity.invincibilityTimer.is_stopped()
	):
		getState('Hit').hitShot = areaOwner
		requestNextState('Hit')
		

func requestNextState(nextState: String):
	if (state == NO_STATE):
		setState(nextState)
	else:
		requestedNextState = nextState
		
		
func _shouldUseNextRequestedState(requestedState: String, delta: float) -> bool:
	return not (state in noInterruptionStates)
	
	
func _startInvincibility():
	entity.invincibilityTimer.start()
	entity.anim.play("invincible_flash")
	yield(entity.invincibilityTimer, "timeout")
	entity.anim.stop()
	entity.sprite.material.set_shader_param("mix_coef", 0.0)
