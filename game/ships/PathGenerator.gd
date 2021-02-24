extends Node
class_name PathGenerator
"""
Utility to generate a movement path for a ship
"""

export(int, 2, 100) var widthSegments: int = 3
export(int, 100) var minSegmentsBetweenPoints: int = 1
export(float) var minHeightStep: float =  15.5
export(float) var maxHeightStep: float = 25.6




func _ready():
	pass # Replace with function body.
