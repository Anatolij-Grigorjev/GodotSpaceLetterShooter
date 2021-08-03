extends ParallaxBackground
"""
Perform automatic scrolling of Parallax BG at fixed rate
"""
enum Direction {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3
}

signal bgWillHaveTurned(newDirection, waitTime)


export(float) var scroll_rate = 120.66
export(Direction) var starsMoveDirection = Direction.DOWN setget _applyMoveDirection


onready var anim: AnimationPlayer = $AnimationPlayer


var directionParams: Array = [
	#UP
	[Vector2(0, -1), Vector2(0, -2)],
	#DOWN
	[Vector2(0, 1), Vector2(0, 2)],
	#LEFT
	[Vector2(-1, 0), Vector2(-2, 0)],
	#RIGHT
	[Vector2(1, 0), Vector2(2, 0)]
]
var directionNames: Array = [
	"up", "down", "left", "right"
]


var runningStandalone: bool = false
var screenShaker: Node2D

func _ready():
	_applyMoveDirection(starsMoveDirection)
	_generateHyperSpeedAnimations()
	_generateHyperTurnAnimations()
	runningStandalone = get_tree().get_nodes_in_group("shooter").empty()
	screenShaker = Utils.getFirst(get_tree().get_nodes_in_group("screen_shake"))
	if (runningStandalone):
		print(anim.get_animation_list())

func _process(delta: float):
	if (runningStandalone):
		if Input.is_action_just_released("debug1"):
			var nextDirection = _getNextRandomDirection()
			var animationName = _getTurnAnimationName(starsMoveDirection, nextDirection)
			anim.play(animationName)
		if Input.is_action_just_released("debug2"):
			#opposite direction
			var opposite = _getOppositeDirection(starsMoveDirection)
			anim.play("hyper_" + directionNames[starsMoveDirection])
			yield(anim, "animation_finished")
			yield(get_tree().create_timer(1.5), "timeout")
			anim.play("hyper_" + directionNames[opposite])
			yield(anim, "animation_finished")
			_applyMoveDirection(starsMoveDirection)
			
	
		scroll_offset += (delta * (Vector2.ONE * scroll_rate))
		

func startHyperTurn():
	var nextDirection: int = _getNextAllowedDirection()
	var animName: String = _getTurnAnimationName(starsMoveDirection, nextDirection)
	var animation: Animation = anim.get_animation(animName)
	screenShaker.beginShake(animation.length, 20, 25, 2)
	emit_signal("bgWillHaveTurned", nextDirection, animation.length)
	anim.play(animName)

	
	
func hide():
	_toggleChildrenVisible(false)
	
	
func show():
	_toggleChildrenVisible(true)


func _toggleChildrenVisible(makeVisible: bool):
	for node in get_children():
		if is_instance_valid(node):
			node.visible = makeVisible


func _applyMoveDirection(direction: int):
	var previouslyHorizontal = _directionHorizontal()
	starsMoveDirection = clamp(direction, Direction.UP, Direction.RIGHT)
	var directionPlaneChanged = _directionHorizontal() != previouslyHorizontal
	var directionVectors = directionParams[direction]
	if ($BigStars):
		$BigStars.motion_scale = directionVectors[0]
		if (directionPlaneChanged):
			$BigStars.motion_mirroring = Utils.swapVector($BigStars.motion_mirroring)
	if ($SmallStars):
		$SmallStars.motion_scale = directionVectors[1]
		if (directionPlaneChanged):
			$SmallStars.motion_mirroring = Utils.swapVector($SmallStars.motion_mirroring)
	
	
func _directionHorizontal() -> bool:
	return starsMoveDirection in [Direction.LEFT, Direction.RIGHT]
	

func _getOppositeDirection(direction: int) -> int:
	if (direction % 2 == 0):
		return direction + 1
	else:
		return direction - 1
	

func _getTurnAnimationName(fromDirection: int, toDirection: int) -> String:
	return "hyper_%s_turn_%s" % [directionNames[fromDirection], directionNames[toDirection]]
	
	
func _getNodeMotionScaleKeyName(node: Node) -> String:
	return "%s:motion_scale" % node.name
	

func _getNextRandomDirection() -> int:
	var directions = Array(Direction.values())
	directions.erase(starsMoveDirection)
	directions.shuffle()
	return Utils.getFirst(directions)
	

func _getNextAllowedDirection() -> int:
	if (starsMoveDirection != Direction.DOWN):
		return Direction.DOWN
	else:
		return Direction.LEFT if randi() % 2 == 0 else Direction.RIGHT

	
func _generateHyperSpeedAnimations():
	for direction in Direction:
		var directionIdx: int = Direction[direction]
		var hyperAnimation = _generateHyperAnimationDirection(directionIdx)
		var animationName = "hyper_%s" % directionNames[directionIdx]
		anim.add_animation(animationName, hyperAnimation)
		

func _generateHyperTurnAnimations():
	for fromDirection in Direction:
		for toDirection in Direction:
			if (fromDirection == toDirection):
				continue
			var fromIdx = Direction[fromDirection]
			var toIdx = Direction[toDirection]
			var animationName = _getTurnAnimationName(fromIdx, toIdx)
			var animation = _generateHyperTurnFromToDirectionAnimation(fromIdx, toIdx)
			anim.add_animation(animationName, animation)
	
	
func _generateHyperAnimationDirection(direction: int) -> Animation:
	var animation: Animation = Animations.createAnimationOfLength(1.0)
	var directionStarsCruiseSpeed = directionParams[direction]
	var bigStarsMotionScaleTrackIdx := Animations.addAnimationValueTrack(animation, _getNodeMotionScaleKeyName($BigStars))
	Animations.addAnimationValueTrackInterpolation(
		animation, bigStarsMotionScaleTrackIdx, 
		directionStarsCruiseSpeed[0], directionStarsCruiseSpeed[0] * 4
	)
	var smallStarsMotionScaleTrackIdx := Animations.addAnimationValueTrack(animation, _getNodeMotionScaleKeyName($SmallStars))
	Animations.addAnimationValueTrackInterpolation(
		animation, smallStarsMotionScaleTrackIdx, 
		directionStarsCruiseSpeed[1], directionStarsCruiseSpeed[1] * 4
	)
	return animation
	
	
func _generateHyperTurnFromToDirectionAnimation(fromDirection: int, toDirection: int) -> Animation:
	var animation = _generateHyperAnimationDirection(fromDirection)
	animation.length = 4.0
	var changeDirMethodTrackIdx = Animations.addAnimationMethodTrack(animation, ".")
	Animations.addAnimationMethodTrackInvocation(
			animation, changeDirMethodTrackIdx, 4.0,
			"_applyMoveDirection", [toDirection]
	)
	var bigStarsTrackIdx = animation.find_track(_getNodeMotionScaleKeyName($BigStars))
	var newDirectionBigStarsCruiseSpeed = directionParams[toDirection][0]
	var prevDirectionBigStarsCruiseSpeed = directionParams[fromDirection][0]
	Animations.addAnimationValueTrackInterpolation(
		animation, bigStarsTrackIdx,
		prevDirectionBigStarsCruiseSpeed * 3, newDirectionBigStarsCruiseSpeed,
		3.0
	)
	var smallStarsTrackIdx = animation.find_track(_getNodeMotionScaleKeyName($SmallStars))
	var newDirectionSmallStarsCruisSpeed = directionParams[toDirection][1]
	var prevDirectionSmallStarsCruisSpeed = directionParams[fromDirection][1]
	Animations.addAnimationValueTrackInterpolation(
		animation, smallStarsTrackIdx,
		prevDirectionSmallStarsCruisSpeed * 3, newDirectionSmallStarsCruisSpeed,
		3.0
	)
	return animation
