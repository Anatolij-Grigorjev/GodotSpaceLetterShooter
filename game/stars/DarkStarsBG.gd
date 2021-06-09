extends ParallaxBackground
"""
Perform automatic scrolling of BG at fixed rate
"""

export(float) var scroll_rate = 120.66


func _process(delta: float):
	scroll_offset.y += (delta * scroll_rate)
