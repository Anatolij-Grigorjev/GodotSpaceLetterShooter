extends StateMachine
class_name ShooterShipStateMachine
"""
FSM for handling states of shooter ship
"""

var collisionNextState: String = NO_STATE
var shootingPressed: bool = false

var requestedNextState: String = NO_STATE

func _ready():
	entity.emptyChamber()
	
	
func _getNextState(delta: float) -> String:
	
	if (requestedNextState != NO_STATE):
		var nextState = requestedNextState
		requestedNextState = NO_STATE
		return nextState
	
	match (state):
		"StartingWave":
			var appearingState = getState(state)
			if (appearingState.animationFinished):
				return "Preparing"
			else:
				return NO_STATE
		"Preparing":
			if (shootingPressed):
				shootingPressed = false
				return "Shooting"
			return NO_STATE
		"Shooting":
			var shootingState = getState(state)
			if (shootingState.shootingDone):
				return "Preparing"
			else:
				return NO_STATE
		"Hit":
			var hitState = getState(state)
			if (hitState.animationFinished):
				return "Preparing"
			else:
				return NO_STATE
		"LeavingWave":
			var leavingWaveState = getState(state)
			if (leavingWaveState.animationFinished):
				return "Leaving"
			return NO_STATE
		"Leaving":
			
			return NO_STATE
		_: 
			breakpoint
			return NO_STATE
	
	
func sceneFireCodeTyped(shootableTarget):
	getState('Shooting').shotTarget = shootableTarget
	shootingPressed = true
		
	
func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		getState('Hit').hitShot = areaOwner
		requestNextState("Hit")
		

func requestNextState(nextState: String):
	if (state == NO_STATE):
		setState(nextState)
	else:
		requestedNextState = nextState
