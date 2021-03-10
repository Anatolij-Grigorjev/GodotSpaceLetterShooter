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


func _ready():
	path = pathGenerator.generatePathSegments(entity.position)
	lastPathPointIdx = 0
	remainingPointIdleTime = pathPointIdleSeconds
	
	
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
	pathMover.resume_all()
	
	
func exitState(nextState: String):
	pathMover.stop_all()
