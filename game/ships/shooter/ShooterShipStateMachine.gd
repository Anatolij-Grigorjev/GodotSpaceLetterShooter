extends StateMachine
class_name ShooterShipStateMachine
"""
FSM for handling states of shooter ship
"""

var collisionNextState: String = NO_STATE
var shipNextTarget = null

func _ready():
	entity.emptyChamber()
	
	
func _getNextState(delta: float) -> String:
	
	if (collisionNextState != NO_STATE):
		var nextState = collisionNextState
		collisionNextState = NO_STATE
		return nextState
	
	match (state):
		"Appearing":
			var appearingState = getState(state)
			if (appearingState.animationFinished):
				return "Preparing"
			else:
				return NO_STATE
		"Preparing":
			if (shipNextTarget != null):
				getState("Shooting").shotTarget = shipNextTarget
				shipNextTarget = null
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
		"Leaving":
			
			return NO_STATE
		_: 
			breakpoint
			return NO_STATE
			
			
func sceneLetterTyped(letter: String):
	getState('Preparing').letterTyped(letter)
	
	
func sceneFireCodeTyped(shootableTarget):
	shipNextTarget = shootableTarget
		
	
func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		emit_signal("shooterHitByShot", areaOwner)
		entity.emptyChamber()
		collisionNextState = "Hit"
		
