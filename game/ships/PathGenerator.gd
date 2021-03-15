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
export(Vector2) var pathBoundsHorizMargins: Vector2 = Vector2(50, 50)
export(bool) var printDebug: bool = false

var screenHorizBounds: Vector2
var screenVertBound: float
var segmentWidth: float


func _ready():
	#vars initialized in ready to use editor values
	screenHorizBounds = Vector2(
		pathBoundsHorizMargins.x, 
		OS.window_size.x - pathBoundsHorizMargins.y
	)
	screenVertBound = OS.window_size.y
	segmentWidth = (
		screenHorizBounds.y - screenHorizBounds.x) / widthSegmentsNum
		
	if (printDebug):
		print("===========PATH-GENERATOR-[%s.%s]=" % [owner.name, name])
		print("Allowed screen horizontal bounds: %s" % screenHorizBounds)
		print("Allowed screen vertical bounds: %s" % screenVertBound)
		print("Segments: %s, width/seg: %s" % [widthSegmentsNum, segmentWidth])
		print("Segements: %s" % [range(screenHorizBounds.x, screenHorizBounds.y + 1, segmentWidth)])
		print("====================================================")
		

func generatePathSegments(startPoint: Vector2) -> Array:
	
	var position: Vector2 = startPoint
	var path: Array = [position]
	while(position.y < screenVertBound):
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
	if (screenHorizBounds.x <= xAfterPathPart and xAfterPathPart <= screenHorizBounds.y):
		return randomDirection
	else:
		return -1 * randomDirection
