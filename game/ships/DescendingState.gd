extends State
class_name DescendingState
"""
State for a txtship to descend according to a path
created by its PathGenerator
"""
export(float) var pathPointIdleSeconds: float = 0.5
export(NodePath) var pathGeneratorPath: NodePath

onready var pathGenerator: PathGenerator = get_node(pathGeneratorPath)
onready var pathMover: Tween = $PathMover


var path: Array = []
var lastPathPointIdx: int = 0
var remainingPointIdleTime: float = 0.0

var pathOver: bool = false
var afterCollideEntityState: String = StateMachine.NO_STATE


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
		entity.disableThrusters()
		remainingPointIdleTime -= delta
		return
	
	#wait at idle point over
	var startPoint = path[lastPathPointIdx]
	lastPathPointIdx += 1
	var endPoint = path[lastPathPointIdx]
	remainingPointIdleTime = pathPointIdleSeconds
	var moveTime = endPoint.distance_to(startPoint) / entity.speed
	pathMover.interpolate_property(
		entity, "position", 
		startPoint, endPoint,  
		moveTime, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	pathMover.start()
	_enableDirectionThruster(startPoint, endPoint)
		
	
	
func enterState(prevState: String):
	.enterState(prevState)
	pathMover.resume_all()
	
	
func exitState(nextState: String):
	.exitState(nextState)
	afterCollideEntityState = StateMachine.NO_STATE
	pathMover.stop_all()
	entity.disableThrusters()
	
	
func _generatePath() -> void:
	path = pathGenerator.generatePathSegments(entity.position)
	lastPathPointIdx = 0
	remainingPointIdleTime = pathPointIdleSeconds
	
	
func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		var collideProjectile = areaOwner
		if (entity.projectileHitText(collideProjectile)):
			var payload: String = collideProjectile.label.text
			if (entity.currentText.length() > payload.length()):
				fsm.hitChars = payload.length()
				afterCollideEntityState = "Hit"
			else: 
				afterCollideEntityState = "Die"
		else:
			afterCollideEntityState = "Miss"
		return
	if (areaOwner.is_in_group("shooter")):
		afterCollideEntityState = "CollideShip"
	
	
func _enableDirectionThruster(startPoint: Vector2, endPoint: Vector2):
	var thruster = (
		entity.thrusterLeft if (startPoint.x < endPoint.x) 
		else entity.thrusterRight
	)
	thruster.emitting = true
