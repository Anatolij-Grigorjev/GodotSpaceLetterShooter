extends State
class_name ShooterShipPreparingState
"""
Shooter 'prepares' to take a shot - receives input and 
chambers the letters
"""
const SpokeScn = preload("res://ships/shooter/VisibleSpoke.tscn")

export(int) var spokesPerLetter = 3

var speed: float = 300



func letterTyped(letter: String):
	_chamberLetter(letter)
	for idx in range(spokesPerLetter):
		_addSpoke()
	

# used for debugging input effects when running without a scene
#func _input(event: InputEvent) -> void:
#	if (not event is InputEventKey):
#		return
#	var keyCharCode: String = OS.get_scancode_string(event.scancode)
#	if (keyCharCode.length() == 1):
#		letterTyped(keyCharCode)
	
	
func _chamberLetter(letter: String):
	entity.chamber += letter
	
	
	
func _addSpoke():
	var spoke = SpokeScn.instance()
	spoke.allowedRotationRange = Vector2(150, 210)
	spoke.scale = Vector2(1, rand_range(1.5, 3))
	spoke.offset = Vector2(0, rand_range(20, 25))
	spoke.visible = false
	
	entity.sprite.add_child(spoke)
	spoke.position = entity.shotPosition.position
	spoke.showSpoke()
