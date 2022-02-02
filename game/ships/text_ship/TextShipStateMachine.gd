extends StateMachine
class_name TextShipStateMachine
"""
FSM for actions of a descending ship with text
"""
export(Dictionary) var initialIdlingActionsWeights = {
	"Idling": 1.0,
	"IdlingBubble": 1.0,
	"IdlingShoot": 1.0
}

var idlingActionsWeights: WeightedItems

var lastCollidedProjectileCell: SingleReadVar = SingleReadVar.new(null)
var lastCollidedShipCell: SingleReadVar = SingleReadVar.new(null)
var shipReachedFinishCell: SingleReadVar = SingleReadVar.new(false)


func _ready():
	if (not idlingActionsWeights):
		idlingActionsWeights = WeightedItems.new(initialIdlingActionsWeights)
	call_deferred("setState", "Appearing")
	yield(get_tree(), "idle_frame")


func _getNextState(delta: float) -> String:
	match (state):
		"Appearing":
			var appearingState = getState(state)
			if appearingState.stateTime >= appearingState.shipAppearingTime:
				return "Descending"
			else:
				return NO_STATE
		"Descending":
			var collisionState = _getLatestAnyCollisionState()
			if (collisionState != NO_STATE):
				return collisionState
			var descendingState = getState(state)
			if (descendingState.segmentOver):
				return _getNextIdlingState()
			return NO_STATE
		"Idling":
			var collisionState = _getLatestAnyCollisionState()
			if (collisionState != NO_STATE):
				return collisionState
			var idlingState = getState(state)
			if (idlingState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		"Hit":
			var hitState = getState("Hit")
			if hitState.stateTime < hitState.hitRecoveryTime:
				return NO_STATE
			if not hitState.shotPayloadWasMatch:
				return previousState
			else:
				if entity.currentText.length() <= 0:
					return "Die"
				else:
					return "Descending"
		"CollideShip":
			return NO_STATE
		"ReachedFinish":
			return NO_STATE
		"Die":
			return NO_STATE
		_: 
			return NO_STATE
			

func _ifAnimationFinishedGoToState(nextState: String) -> String:
	var animatedState: AnimationState = getState(state)
	if animatedState.animationFinished:
		return nextState
	else:
		return NO_STATE


func _onBodyEntered(area: Node):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		lastCollidedProjectileCell.write(areaOwner)
	if (areaOwner.is_in_group("shooter")):
		lastCollidedShipCell.write(areaOwner)
	#access to physics properties only exist during frame of collision
	#so this is set immediately when handling signal
	getState("Hit").setCollisionShotProperties(areaOwner)
	#TODO: make this condition work with bodies
	if(area.is_in_group("textShipFinish")):
		shipReachedFinishCell.write(true)
		
		
func _getProjectileAttemptedHitState(projectile: Node2D) -> String:
	if not is_instance_valid(projectile):
		return NO_STATE
	return "Hit"
		
		
func _getShipAttemptedCollisionState(ship: Node2D) -> String:
	return "CollideShip"
	
	
func _getShipReachedFinishState() -> String:
	return "ReachedFinish"
	

func _getLatestAnyCollisionState() -> String:
	var nonProjectileCollisions = _getNextNonProjectileCollisionsState()
	if nonProjectileCollisions != NO_STATE:
		return nonProjectileCollisions
	
	if lastCollidedProjectileCell.present():
		return _getProjectileAttemptedHitState(lastCollidedProjectileCell.readAndReset())
	
	return NO_STATE
	
	
func _getNextNonProjectileCollisionsState() -> String:
	if lastCollidedShipCell.present():
		return _getShipAttemptedCollisionState(lastCollidedShipCell.readAndReset())
	if shipReachedFinishCell.present():
		return _getShipReachedFinishState()
		
	return NO_STATE
	

func _getNextIdlingState() -> String:
	return idlingActionsWeights.pickRandomWeighted()
