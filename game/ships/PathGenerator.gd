extends Node
class_name PathGenerator
"""
Utility to generate a movement path for a ship
"""
enum Direction {
	LEFT = -1,
	RIGHT = 1
}

export(int, 2, 100) var widthSegmentsNum: int = 3
export(int, 100) var minSegmentsBetweenPoints: int = 1
export(float) var minHeightStep: float =  15.5
export(float) var maxHeightStep: float = 25.6

var screenBounds: Vector2 = OS.window_size
var segmentWidth: float = screenBounds.x / widthSegmentsNum


func _ready():
	pass # Replace with function body.
	

func generatePathSegments(startPoint: Vector2) -> Array:
	
	var position: Vector2 = startPoint
	var path: Array = [position]
	while(position.y < screenBounds.y):
		var direction: int = _getNextSegmentDirection(position.x)
		var moveAmount: Vector2 = Vector2(
			direction * (minSegmentsBetweenPoints + rand_range(0, 1.0)) * segmentWidth,
			rand_range(minHeightStep, maxHeightStep)
		)
		var nextPosition = position + moveAmount
		path.push_back(nextPosition)
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
	var xAfterPathPart = currentX + (randomDirection * segmentWidth * (minSegmentsBetweenPoints + 1))
	if (0 <= xAfterPathPart and xAfterPathPart <= screenBounds.x):
		return randomDirection
	else:
		return -1 * randomDirection
