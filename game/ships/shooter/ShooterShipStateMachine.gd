extends StateMachine
class_name ShooterShipStateMachine
"""
FSM for handling states of shooter ship
"""
var requestedNextState: String = NO_STATE

var lastTargetedShootableCell: SingleReadVar = SingleReadVar.new(null)
var shootCommandJustPressedCell: SingleReadVar = SingleReadVar.new(false)
var lastHitShotCell: SingleReadVar = SingleReadVar.new(null)


func _ready():
	entity.emptyChamber()
	
	
func _getNextState(delta: float) -> String:
	
	var shipWasHit: bool = false
	if lastHitShotCell.present():
		getState('Hit').hitShot = lastHitShotCell.readAndReset()
		shipWasHit = true
	
	match (state):
		"StartingFirstWave":
			return _ifAnimationFinishedGoToState("Preparing")
		"StartingNextWave":
			return _ifAnimationFinishedGoToState("Preparing")
		"Preparing":
			if shipWasHit:
				return 'Hit'
			if shootCommandJustPressedCell.readAndReset():
				getState('Shooting').shotTarget = lastTargetedShootableCell.readAndReset()
				return 'Shooting'
			return NO_STATE
		"Shooting":
			if shipWasHit:
				return 'Hit'
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
	shootCommandJustPressedCell.write(true)
	lastTargetedShootableCell.write(shootableTarget)
	
	
func onSceneLetterTyped(letter: String):
	if (state == 'Preparing'):
		getState(state).letterTyped(letter)
	
		
func _onShapeEntered(shape):
	if (
		shape.is_in_group('projectile') 
		and entity.invincibilityTimer.is_stopped()
	):
		lastHitShotCell.write(shape)
	
	
func _startInvincibility():
	entity.invincibilityTimer.start()
	entity.anim.play("invincible_flash")
	yield(entity.invincibilityTimer, "timeout")
	entity.anim.stop()
	entity.sprite.material.set_shader_param("mix_coef", 0.0)
