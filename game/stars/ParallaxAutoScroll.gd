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


func _ready():
	_applyMoveDirection(starsMoveDirection)


func _process(delta: float):
	if _directionHorizontal():
		scroll_offset.x += (delta * scroll_rate)
	else:
		scroll_offset.y += (delta * scroll_rate)
		
	
	
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
