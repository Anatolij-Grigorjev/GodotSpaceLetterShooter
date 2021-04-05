extends StateMachine
class_name TextShipStateMachine
"""
FSM for actions of a descending ship with text
"""

var hitChars: int = 1
var collisionNextState: String = NO_STATE

onready var pathGenerator: PathGenerator = $PathGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_generateDescendPath")
	call_deferred("setState", "Appearing")


func _getNextState(delta: float) -> String:
	
	if (collisionNextState != NO_STATE):
		var nextState = collisionNextState
		collisionNextState = NO_STATE
		return nextState
	
	match (state):
		"Appearing":
			var appearingState = getState(state)
			if (appearingState.animationFinished):
				return "Descending"
			else:
				return NO_STATE
		"Descending":
			var descendingState = getState(state)
			if (descendingState.segmentOver):
				return _getNextIdlingState()
			return NO_STATE
		"Idling":
			var idlingState = getState(state)
			if (idlingState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		"IdlingBubble":
			var idlingBubbleState = getState(state)
			if (idlingBubbleState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		"IdlingShoot":
			var idlingShootState = getState(state)
			if (idlingShootState.idlingOver):
				return "Descending"
			else:
				return NO_STATE
		"Hit":
			var hitState = getState(state)
			if (hitState.animationFinished):
				return "Descending"
			else:
				return NO_STATE
		"Miss":
			var missState = getState(state)
			if (missState.animationFinished):
				return "Descending"
			else:
				return NO_STATE
		"CollideShip":
			return NO_STATE
		"Die":
			return NO_STATE
		_: 
			breakpoint
			return NO_STATE


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		if (entity.bubble.bubbleHit):
			return
		var collideProjectile = areaOwner
		if (entity.projectileHitText(collideProjectile)):
			var payload: String = collideProjectile.label.text
			if (entity.currentText.length() > payload.length()):
				hitChars = payload.length()
				collisionNextState = "Hit"
			else: 
				collisionNextState = "Die"
		else:
			collisionNextState = "Miss"
		return
	if (areaOwner.is_in_group("shooter")):
		collisionNextState = "CollideShip"


func _generateDescendPath():
	var path = pathGenerator.generatePathSegments(entity.position)
	getState("Descending").descendPath = path
	

func _getNextIdlingState() -> String:
	var weights: Dictionary = entity.idlingActionsWeights
	var randomThrow := randi() % 100
	var remainingUncertainty := float(randomThrow)
	var weightUnitValue: float = _calcChanceOfWeightUnit(weights)
	var nextIdlingState = NO_STATE
	for state in weights:
		var stateWeight: float = weights[state]
		remainingUncertainty -= (stateWeight * weightUnitValue)
		if (remainingUncertainty < 0.0):
			nextIdlingState = state
			break
	_increaseNonZeroWeightsExcept(weights, nextIdlingState)
	return nextIdlingState
	
	
func _calcChanceOfWeightUnit(weights: Dictionary) -> float:
	var allWeightsArray: Array = weights.values()
	var sum := 0.0
	for weight in allWeightsArray:
		sum += weight
	return 100.0 / (max(sum, 1.0))
	
	
func _increaseNonZeroWeightsExcept(weights: Dictionary, ignoreKey: String):
	for key in weights:
		var weight = weights[key]
		if (key == ignoreKey or weight == 0.0):
			continue
		else:
			weights[key] = weights[key] + 1.0

