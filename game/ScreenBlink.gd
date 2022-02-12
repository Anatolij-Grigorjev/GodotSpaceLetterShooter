extends CanvasLayer
"""
Canvas layer used to flash a specific color on the screen for a short durarion
Loaded as singleton
"""
export(Color) var defaultBlinkColor: Color = Color.white
export(float) var defaultDuration: float = 0.15

onready var blinkRect = $ColorRect
onready var timer = $Timer


func _ready():
	timer.connect("timeout", self, "_onBlinkTimeout")
	_hideRect()
	
	
func blink(blinkColor: Color = defaultBlinkColor, duration: float = defaultDuration):
	timer.wait_time = duration
	blinkRect.color = blinkColor
	timer.start()
	blinkRect.visible = true
	
	
func _onBlinkTimeout():
	_hideRect()


func _hideRect():
	blinkRect.visible = false
	timer.stop()
