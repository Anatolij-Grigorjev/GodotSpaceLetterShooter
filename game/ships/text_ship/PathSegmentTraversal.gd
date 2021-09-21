class_name PathSegmentTraversal
"""
Model to describe state of a path segment in relation to abilities of 
specific ship
"""

var startPoint: Vector2
var endPoint: Vector2
var traversalTime: float

func _init(start: Vector2, end: Vector2, moveTime: float):
	startPoint = start
	endPoint = end
	traversalTime = moveTime
	
	
func traverseDirectionSign() -> float:
	return sign(endPoint.x - startPoint.x)
