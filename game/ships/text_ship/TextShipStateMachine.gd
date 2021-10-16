extends StateMachine
class_name TextShipStateMachine
"""
FSM for actions of a descending ship with text
"""
const NO_STATE_MATCHED = "<???>"

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
			return _ifAnimationFinishedGoToState("Descending")
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
			return _ifAnimationFinishedGoToState("Descending")
		"Miss":
			return _ifAnimationFinishedGoToState("Descending")
		"CollideShip":
			return NO_STATE
		"ReachedFinish":
			return NO_STATE
		"Die":
			return NO_STATE
		_: 
			return NO_STATE_MATCHED
			

func _ifAnimationFinishedGoToState(nextState: String) -> String:
	var animatedState: AnimationState = getState(state)
	if animatedState.animationFinished:
		return nextState
	else:
		return NO_STATE


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		lastCollidedProjectileCell.write(areaOwner)
	if (areaOwner.is_in_group("shooter")):
		lastCollidedShipCell.write(areaOwner)
	if(area.is_in_group("textShipFinish")):
		shipReachedFinishCell.write(true)
		
		
func _getProjectileAttemptedHitState(projectile: Node2D) -> String:
	if not is_instance_valid(projectile):
		return NO_STATE
	if not entity.projectileHitText(projectile):
		return "Miss"
	var payload: String = projectile.getText()
	if (entity.currentText.length() > payload.length()):
		getState("Hit").hitChars = payload.length()
		return "Hit"
	else: 
		get_node("Die").finalShotLettersNum = entity.currentText.length()
		return "Die"
		
		
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
	
	
func _stateDecided(checkState: String) -> bool:
	return checkState != NO_STATE_MATCHED

