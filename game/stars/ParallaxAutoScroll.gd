extends ParallaxBackground
"""
Perform automatic scrolling of Parallax BG at fixed rate
"""

export(float) var scroll_rate = 120.66


func _process(delta: float):
	scroll_offset.y += (delta * scroll_rate)
	
	
func hide():
	_toggleChildrenVisible(false)
	
	
func show():
	_toggleChildrenVisible(true)


func _toggleChildrenVisible(makeVisible: bool):
	for node in get_children():
		if is_instance_valid(node):
			node.visible = makeVisible
