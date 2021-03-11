extends State
class_name DescendingState
"""
State for a txtship to descend according to a path
created by its PathGenerator
"""

export(float) var speed: float = 450
export(float) var pathPointIdleSeconds: float = 0.5

onready var pathGenerator = $PathGenerator
onready var pathMover: Tween = $PathMover


var path: Array = []
var lastPathPointIdx: int = 0
var remainingPointIdleTime: float = 0.0

var pathOver: bool = false
var collideProjectileState: String = StateMachine.NO_STATE



func _ready():
	call_deferred("_generatePath")
	
	
func processState(delta: float):
	if (pathOver):
		return
		
	#moving between path points
	if pathMover.is_active():
		return
	
	#path over
	if (lastPathPointIdx >= path.size() - 1):
		pathOver = true
		return
	#waiting at a point
	if remainingPointIdleTime > 0:
		remainingPointIdleTime -= delta
		return
	
	#wait at idle point over
	var startPoint = path[lastPathPointIdx]
	lastPathPointIdx += 1
	var endPoint = path[lastPathPointIdx]
	remainingPointIdleTime = pathPointIdleSeconds
	var moveTime = endPoint.distance_to(startPoint) / speed
	pathMover.interpolate_property(
		entity, "position", 
		startPoint, endPoint,  
		moveTime, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	pathMover.start()
	
	
func enterState(prevState: String):
	.enterState(prevState)
#	collideProjectileState = StateMachine.NO_STATE
	pathMover.resume_all()
	
	
func exitState(nextState: String):
	.exitState(nextState)
	collideProjectileState = StateMachine.NO_STATE
	pathMover.stop_all()
	
	
func _generatePath() -> void:
	path = pathGenerator.generatePathSegments(entity.position)
	lastPathPointIdx = 0
	remainingPointIdleTime = pathPointIdleSeconds
	
	
func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		var collideProjectile = areaOwner
		if (entity.projectileHitText(collideProjectile)):
			if (entity.currentText.length() > 1):
				collideProjectileState = "Hit"
			else: 
				collideProjectileState = "Die"
		else:
			collideProjectileState = "Miss"
