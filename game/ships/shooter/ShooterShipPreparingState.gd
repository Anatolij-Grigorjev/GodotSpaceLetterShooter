extends State
class_name ShooterShipPreparingState
"""
Shooter 'prepares' to take a shot - receives input and 
chambers the letters
"""
const SpokeScn = preload("res://ships/shooter/VisibleSpoke.tscn")

var speed: float = 300

func _ready():
	pass
	
	
func processState(delta: float):
	.processState(delta)
	if (Input.is_action_pressed("move_ship_left")):
		entity.position.x -= (speed * delta)
	if (Input.is_action_pressed("move_ship_right")):
		entity.position.x += (speed * delta)


func letterTyped(letter: String):
	_chamberLetter(letter)
	_addSpoke()
	
	
	
func _chamberLetter(letter: String):
	entity.chamber += letter
	
	
	
func _addSpoke():
	var spoke = SpokeScn.instance()
	spoke.allowedRotationRange = Vector2(150, 210)
	spoke.scale = Vector2(0.1, 3)
	spoke.offset = Vector2(0, 50)
	spoke.visible = false
	
	entity.sprite.add_child(spoke)
	spoke.showSpoke()
