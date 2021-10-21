extends Node
class_name PathGenerator
"""
Utility to generate a movement path for a ship
"""
enum Direction {
	LEFT = -1,
	RIGHT = 1
}

export(float) var minWidthPrcPerMove: float = 0.1
export(float) var maxWidthPrcPerMove: float = 0.21
export(float) var minHeightStep: float =  15.5
export(float) var maxHeightStep: float = 25.6
export(float) var pathHorizontalMarginLeft: float = 50
export(float) var pathHorizontalMarginRight: float = 50
export(bool) var printDebug: bool = false

var screenHorizBounds: Vector2
var screenVertBound: float

var horizontalMoveLengthBounds: Vector2


func _ready():
	#vars initialized in ready to use editor values
	screenHorizBounds = Vector2(
		pathHorizontalMarginLeft, 
		OS.window_size.x - pathHorizontalMarginRight
	)
	screenVertBound = OS.window_size.y
	var allowedHorizMoveAreaLength = screenHorizBounds.y - screenHorizBounds.x
	horizontalMoveLengthBounds = Vector2(
		allowedHorizMoveAreaLength * minWidthPrcPerMove,
		allowedHorizMoveAreaLength * maxWidthPrcPerMove
	)
		
	if (printDebug):
		print("===========[%s.%s]===========" % [owner.name, name])
		print("Allowed screen horizontal bounds: %s" % screenHorizBounds)
		print("Allowed screen vertical bounds: %s" % Vector2(0, screenVertBound))
		print("One horizontal move step range: %s" % horizontalMoveLengthBounds)
		print("One vertical move step range: %s" % Vector2(minHeightStep, maxHeightStep))
		print("====================================================")
		

func generatePathSegments(startPoint: Vector2) -> Array:
	
	var position: Vector2 = startPoint
	var path: Array = [position]
	while(position.y < screenVertBound):
		var direction: int = _getNextSegmentDirection(position.x)
		var moveAmount: Vector2 = Vector2(
			direction * rand_range(horizontalMoveLengthBounds.x, horizontalMoveLengthBounds.y),
			rand_range(minHeightStep, maxHeightStep)
		)
		var nextPosition = position + moveAmount
		path.append(nextPosition)
		position = nextPosition
		
	return path


func _getNextSegmentDirection(currentX: float) -> int:
	#decide random direction
	var randomDirection: int = 0
	if (randi() % 2 > 0):
		randomDirection = Direction.RIGHT
	else:
		randomDirection = Direction.LEFT
	
	#validate picked direction - must move on-screen
	var xAfterPathPart = currentX + (randomDirection * horizontalMoveLengthBounds.y)
	if (screenHorizBounds.x <= xAfterPathPart and xAfterPathPart <= screenHorizBounds.y):
		return randomDirection
	else:
		return -1 * randomDirection
