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
	var fullShooterDistance: float = abs(G.shooterShip.position.y - entity.startPosition.y)
	var relativeTravel: float = (
		abs(entity.startPosition.y - entity.position.y)
		 / fullShooterDistance
	)
	
	var bubbleChanceModifier: float
	if (relativeTravel < 0.34):
		bubbleChanceModifier = 0.67
	elif (relativeTravel < 0.67):
		bubbleChanceModifier = 1.0
	else:
		bubbleChanceModifier = 1.5
		
	var idleBubble: bool = (randi() % 100) < (bubbleChanceModifier * entity.bubbleChancePrc)
	if (idleBubble):
		return "IdlingBubble"
	else:
		return "Idling"
	
