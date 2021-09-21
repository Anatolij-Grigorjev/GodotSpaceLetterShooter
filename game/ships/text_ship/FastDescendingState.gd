extends DescendingState
class_name FastDescendingState
"""
Descending state subtype that creates illusion of faster descend
"""

func _startNextPathSegment():
	var traversal: PathSegmentTraversal = ._startNextPathSegment()
	pathMover.interpolate_property(
		entity, "rotation_degrees", 
		0, traversal.traverseDirectionSign() * 360,  
		traversal.traversalTime, 
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	pathMover.start()
	
