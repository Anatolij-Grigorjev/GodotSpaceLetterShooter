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

var directionProps = {
	Direction.UP: {
		"bigStarCruiseSpeed": Vector2(0, -1),
		"smallStarCruiseSpeed": Vector2(0, -2),
		"name": "up",
		"spritesRotation": 0
	},
	Direction.DOWN: {
		"bigStarCruiseSpeed": Vector2(0, 1),
		"smallStarCruiseSpeed": Vector2(0, 2),
		"name": "down",
		"spritesRotation": 0
	},
	Direction.LEFT: {
		"bigStarCruiseSpeed": Vector2(-1, 0),
		"smallStarCruiseSpeed": Vector2(-2, 0),
		"name": "left",
		"spritesRotation": 270
	},
	Direction.RIGHT: {
		"bigStarCruiseSpeed": Vector2(1, 0),
		"smallStarCruiseSpeed": Vector2(2, 0),
		"name": "right",
		"spritesRotation": 90
	}
}


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
			print(animationName)
			anim.play(animationName)
		if Input.is_action_just_released("debug2"):
			#opposite direction
			var opposite = _getOppositeDirection(starsMoveDirection)
			anim.play("hyper_" + directionProps[starsMoveDirection].name)
			yield(anim, "animation_finished")
			yield(get_tree().create_timer(1.5), "timeout")
			anim.play("hyper_" + directionProps[opposite].name)
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
	
	
func startHyper():
	var animName = _getHyperAnimationName(starsMoveDirection)
	var animation: Animation = anim.get_animation(animName)
	screenShaker.beginShake(animation.length + 5.0, 20, 25, 2)
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
	if ($BigStars):
		$BigStars.motion_scale = directionProps[direction].bigStarCruiseSpeed
		_setChildSpritesRotation($BigStars, directionProps[direction].spritesRotation)
		if (directionPlaneChanged):
			$BigStars.motion_mirroring = Utils.swapVector($BigStars.motion_mirroring)
	if ($SmallStars):
		$SmallStars.motion_scale = directionProps[direction].smallStarCruiseSpeed
		_setChildSpritesRotation($SmallStars, directionProps[direction].spritesRotation)
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
	return "hyper_%s_turn_%s" % [
		directionProps[fromDirection].name, 
		directionProps[toDirection].name
	]
	

func _getHyperAnimationName(direction: int) -> String:
	return "hyper_%s" % directionProps[direction].name
	
	
func _getNodeMotionScaleKeyName(node: Node) -> String:
	return "%s:motion_scale" % node.name
	
	
func _setChildSpritesRotation(parent: Node, newRotation: float):
	for childNode in parent.get_children():
		var childSprite: Sprite = childNode as Sprite
		if is_instance_valid(childSprite):
			childSprite.rotation_degrees = newRotation
	

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
		var animationName = _getHyperAnimationName(directionIdx)
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
	var starsDirectionProps = directionProps[direction]
	var bigStarsMotionScaleTrackIdx := Animations.addAnimationValueTrack(animation, _getNodeMotionScaleKeyName($BigStars))
	Animations.addAnimationValueTrackInterpolation(
		animation, bigStarsMotionScaleTrackIdx, 
		starsDirectionProps.bigStarCruiseSpeed, starsDirectionProps.bigStarCruiseSpeed * 4
	)
	var smallStarsMotionScaleTrackIdx := Animations.addAnimationValueTrack(animation, _getNodeMotionScaleKeyName($SmallStars))
	Animations.addAnimationValueTrackInterpolation(
		animation, smallStarsMotionScaleTrackIdx, 
		starsDirectionProps.smallStarCruiseSpeed, starsDirectionProps.smallStarCruiseSpeed * 4
	)
	return animation
	
	
func _generateHyperTurnFromToDirectionAnimation(fromDirection: int, toDirection: int) -> Animation:
	var animation = _generateHyperAnimationDirection(fromDirection)
	animation.length = 4.0
	var changeDirMethodTrackIdx = Animations.addAnimationMethodTrack(animation, ".")
	Animations.addAnimationMethodTrackInvocation(
			animation, changeDirMethodTrackIdx, animation.length,
			"_applyMoveDirection", [toDirection]
	)
	var bigStarsTrackIdx = animation.find_track(_getNodeMotionScaleKeyName($BigStars))
	var newDirectionBigStarsCruiseSpeed = directionProps[toDirection].bigStarCruiseSpeed
	var prevDirectionBigStarsCruiseSpeed = directionProps[fromDirection].bigStarCruiseSpeed
	Animations.addAnimationValueTrackInterpolation(
		animation, bigStarsTrackIdx,
		prevDirectionBigStarsCruiseSpeed * 3, prevDirectionBigStarsCruiseSpeed,
		2.0, 1.0, 1.5
	)
	Animations.addAnimationValueTrackInterpolation(
		animation, bigStarsTrackIdx,
		prevDirectionBigStarsCruiseSpeed, newDirectionBigStarsCruiseSpeed,
		3.0, 1.0, 0.5
	)
	var smallStarsTrackIdx = animation.find_track(_getNodeMotionScaleKeyName($SmallStars))
	var newDirectionSmallStarsCruisSpeed = directionProps[toDirection].smallStarCruiseSpeed
	var prevDirectionSmallStarsCruisSpeed = directionProps[fromDirection].smallStarCruiseSpeed
	Animations.addAnimationValueTrackInterpolation(
		animation, smallStarsTrackIdx,
		prevDirectionSmallStarsCruisSpeed * 3, prevDirectionSmallStarsCruisSpeed,
		2.0, 1.0, 1.5
	)
	Animations.addAnimationValueTrackInterpolation(
		animation, smallStarsTrackIdx,
		prevDirectionSmallStarsCruisSpeed, newDirectionSmallStarsCruisSpeed,
		3.0, 1.0, 0.5
	)
	return animation
