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


# Called when the node enters the scene tree for the first time.
func _ready():
	if (not idlingActionsWeights):
		idlingActionsWeights = WeightedItems.new(initialIdlingActionsWeights)
	call_deferred("setState", "Appearing")
	Utils.tryConnect(getState("IdlingShoot"), "shotLettersDepleted", self, "_onEntityNotEnoughShotLetters")
	yield(get_tree(), "idle_frame")
	Utils.tryConnect(entity.bubble, "bubbleBurst", self, "_onEntityBubbleBurst")


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
		"IdlingBubble":
			if not lastCollidedShipCell.empty():
				return _getShipAttemptedCollisionState(lastCollidedShipCell.readAndReset())
				
			var idlingBubbleState = getState(state)
			if (idlingBubbleState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		"IdlingShoot":
			var collisionState = _getLatestAnyCollisionState()
			if (collisionState != NO_STATE):
				return collisionState
			var idlingShootState = getState(state)
			if (idlingShootState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		"Hit":
			return _ifAnimationFinishedGoToState("Descending")
		"Miss":
			return _ifAnimationFinishedGoToState("Descending")
		"CollideShip":
			return NO_STATE
		"Die":
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


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		lastCollidedProjectileCell.write(areaOwner)
	if (areaOwner.is_in_group("shooter")):
		lastCollidedShipCell.write(areaOwner)
		
		
func _getProjectileAttemptedHitState(projectile: Node2D) -> String:
	
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
	

func _getLatestAnyCollisionState() -> String:
	if not lastCollidedShipCell.empty():
		return _getShipAttemptedCollisionState(lastCollidedShipCell.readAndReset())
	if not lastCollidedProjectileCell.empty():
		return _getProjectileAttemptedHitState(lastCollidedProjectileCell.readAndReset())
		
	return NO_STATE
	


func _getNextIdlingState() -> String:
	return idlingActionsWeights.pickRandomWeighted()
	
	
func _onEntityBubbleBurst():
	entity.shipHasShield = false
	idlingActionsWeights.disableItem("IdlingBubble")
	if idlingActionsWeights.isItemDisabled("Idling"):
		idlingActionsWeights.setItemWeight("Idling", 1)
	

func _onEntityNotEnoughShotLetters(lettersLeft: int):
	idlingActionsWeights.disableItem("IdlingShoot")

