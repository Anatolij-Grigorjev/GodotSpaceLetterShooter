extends State
class_name DescendingState
"""
State for a txtship to descend according to a path
created by its PathGenerator
"""
onready var pathMover: Tween = $PathMover

var descendPath: Array = [] setget setNewPath
var lastPathPointIdx: int = 0

var segmentOver: bool = false
var pathOver: bool = false


func _ready():
	pass
	
	
func processState(delta: float):
	if (pathOver):
		return
		
	#moving between path points
	if pathMover.is_active():
		return
	
	#pathMover no longer active
	segmentOver = true
	
	#path over
	if (lastPathPointIdx >= descendPath.size() - 1):
		pathOver = true
		return
	
	
func enterState(prevState: String):
	.enterState(prevState)
	if (segmentOver and not pathOver):
		_startNextPathSegment()
	else:
		segmentOver = false
		pathMover.resume_all()
	
	
func exitState(nextState: String):
	.exitState(nextState)
	pathMover.stop_all()
	entity.disableThrusters()
	
	
func _startNextPathSegment():
	segmentOver = false
	var startPoint = descendPath[lastPathPointIdx]
	lastPathPointIdx += 1
	var endPoint = descendPath[lastPathPointIdx]
	var moveTime = endPoint.distance_to(startPoint) / entity.speed
	pathMover.interpolate_property(
		entity, "position", 
		startPoint, endPoint,  
		moveTime, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	pathMover.start()
	_enableDirectionThruster(startPoint, endPoint)
	
	
func _enableDirectionThruster(startPoint: Vector2, endPoint: Vector2):
	var thruster = (
		entity.thrusterLeft if (startPoint.x < endPoint.x) 
		else entity.thrusterRight
	)
	thruster.emitting = true
	_playThrustersAudio()
	
	
func _playThrustersAudio():
	var audioPlayer: AudioStreamPlayer = entity.thrustersAudio as AudioStreamPlayer
	audioPlayer.pitch_scale = 1 + rand_range(-0.05, 0.05)
	audioPlayer.volume_db = 1 + rand_range(-0.05, 0.05)
	audioPlayer.playing = true
	

func setNewPath(path: Array):
	descendPath = path
	lastPathPointIdx = 0
