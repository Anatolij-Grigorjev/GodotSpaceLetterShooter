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
export(float) var scroll_rate = 120.66
export(Direction) var starsMoveDirection = Direction.DOWN setget _applyMoveDirection


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


func _ready():
	_applyMoveDirection(starsMoveDirection)
	_generateHyperSpeedAnimations()
	_generateHyperTurnAnimations()
	runningStandalone = get_tree().get_nodes_in_group("shooter").empty()
	

func _process(delta: float):
	if (runningStandalone):
		if Input.is_action_just_released("debug1"):
			var nextDirection = _getNextRandomDirection()
			var animationName = _getTurnAnimationName(starsMoveDirection, nextDirection)
			$AnimationPlayer.play(animationName)
		if Input.is_action_just_released("debug2"):
			#opposite direction
			var opposite = _getOppositeDirection(starsMoveDirection)
			$AnimationPlayer.play("hyper_" + directionNames[starsMoveDirection])
			yield($AnimationPlayer, "animation_finished")
			yield(get_tree().create_timer(1.5), "timeout")
			$AnimationPlayer.play("hyper_" + directionNames[opposite])
			yield($AnimationPlayer, "animation_finished")
			_applyMoveDirection(starsMoveDirection)
			print(directionParams)
	
		scroll_offset += (delta * (Vector2.ONE * scroll_rate))

	
	
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
	

func _getNextRandomDirection() -> int:
	var directions = Array(Direction.values())
	directions.erase(starsMoveDirection)
	directions.shuffle()
	return Utils.getFirst(directions)
	
	
func _generateHyperSpeedAnimations():
	for direction in Direction:
		var directionIdx: int = Direction[direction]
		var hyperAnimation = _generateHyperAnimationDirection(directionIdx)
		var animationName = "hyper_%s" % directionNames[directionIdx]
		$AnimationPlayer.add_animation(animationName, hyperAnimation)
		

func _generateHyperTurnAnimations():
	for fromDirection in Direction:
		for toDirection in Direction:
			if (fromDirection == toDirection):
				continue
			var fromIdx = Direction[fromDirection]
			var toIdx = Direction[toDirection]
			var animationName = _getTurnAnimationName(fromIdx, toIdx)
			var animation = _generateHyperTurnFromToDirectionAnimation(fromIdx, toIdx)
			$AnimationPlayer.add_animation(animationName, animation)
	
	
func _generateHyperAnimationDirection(direction: int) -> Animation:
	var animation: Animation = Animation.new()
	animation.length = 1.0
	var directionStarsCruiseSpeed = directionParams[direction]
	var bigStarsMotionScaleTrackIdx := _addAnimationTrackMotionScale(animation, $BigStars.name)
	_addAnimationTrackValueInterpolation(
		animation, bigStarsMotionScaleTrackIdx,
		directionStarsCruiseSpeed[0], directionStarsCruiseSpeed[0] * 4,
		1.0
	)
	var smallStarsMotionScaleTrackIdx := _addAnimationTrackMotionScale(animation, $SmallStars.name)
	_addAnimationTrackValueInterpolation(
		animation, smallStarsMotionScaleTrackIdx,
		directionStarsCruiseSpeed[1], directionStarsCruiseSpeed[1] * 4,
		1.0
	)
	return animation
	
	
func _generateHyperTurnFromToDirectionAnimation(fromDirection: int, toDirection: int) -> Animation:
	var animation = _generateHyperAnimationDirection(fromDirection)
	animation.length = 4.0
	var changeDirMethodTrackIdx = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(changeDirMethodTrackIdx, '.')
	animation.track_insert_key(changeDirMethodTrackIdx, 1.0, {
		"method": "_applyMoveDirection",
		"args": [toDirection]
	})
	var bigStarsTrackIdx = animation.find_track($BigStars.name + ":motion_scale")
	var newDirectionBigStarsCruiseSpeed = directionParams[toDirection][0]
	_addAnimationTrackValueInterpolation(
		animation, bigStarsTrackIdx,
		newDirectionBigStarsCruiseSpeed * 3, newDirectionBigStarsCruiseSpeed,
		1.0, 3.0
	)
	var smallStarsTrackIdx = animation.find_track($SmallStars.name + ":motion_scale")
	var newDirectionSmallStarsCruisSpeed = directionParams[toDirection][1]
	_addAnimationTrackValueInterpolation(
		animation, smallStarsTrackIdx,
		newDirectionSmallStarsCruisSpeed * 3, newDirectionSmallStarsCruisSpeed,
		1.0, 3.0
	)
	return animation
	
	

func _addAnimationTrackMotionScale(animation: Animation, nodeName: String) -> int:
	var trackIdx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(trackIdx, nodeName + ":motion_scale")
	return trackIdx


func _addAnimationTrackValueInterpolation(animation: Animation, trackIdx: int, fromValue, toValue, lengthTime: float, fromTime: float = 0.0):
	animation.track_insert_key(trackIdx, fromTime, fromValue)
	animation.track_insert_key(trackIdx, fromTime + lengthTime, toValue)
