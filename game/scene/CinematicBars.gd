extends Control
"""
Bars that create cinematic letterbox effect onscreen. 
Useful for cutscenes
"""

onready var anim: AnimationPlayer = $AnimationPlayer
onready var bottomBar: TextureRect = $BottomBar
onready var topBar: TextureRect = $TopBar


var vertSceenSize: int

func _ready():
	vertSceenSize = OS.window_size.y
	

func fadeIn():
	yield(_waitForCurrentAnimationToFinish(), "completed")
	if not barsVisible():
		anim.play("fade_in")

func fadeOut():
	yield(_waitForCurrentAnimationToFinish(), "completed")
	if barsVisible():
		anim.play_backwards("fade_in")
		
		
func barsVisible() -> bool:
	return (
		is_equal_approx(topBar.rect_position.y, 0) 
		or 
		is_equal_approx(bottomBar.rect_position.y, vertSceenSize - bottomBar.rect_size.y)
	)


func _waitForCurrentAnimationToFinish():
	if anim.is_playing():
		yield(anim, "animation_finished")
	else:
		yield(get_tree(), "idle_frame")
