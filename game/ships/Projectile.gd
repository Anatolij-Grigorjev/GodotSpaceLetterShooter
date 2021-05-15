extends Node2D
"""
Controller for non-homing forward facing projectile
"""
signal projectileDestroyed(text)
signal projectileMissed

export(float) var speed: float = 1050.77
export(float) var angularVelocity: float = 6

var fireDirection: Vector2 = Vector2.ZERO

onready var sprite: Sprite = $Sprite
onready var label: Label = $Label
onready var area: Area2D = $Area2D


var hadCollision: bool = false


func _ready():
	pass
	


func _process(delta):
	sprite.rotation_degrees += angularVelocity
	var velocity = fireDirection * speed
	position += (velocity * delta)



func _on_Area2D_area_entered(area: Area2D):
	hadCollision = true
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("bubble")):
		fireDirection = fireDirection.bounce(fireDirection)
		return
	if (areaOwner.is_in_group("projectile")):
		speed = 0.0
		emit_signal("projectileDestroyed", label.text)
	$AnimationPlayer.play("collide")


func _on_VisibilityNotifier2D_screen_exited():
	#projectile didnt miss if it bounced of a shield
	if (not hadCollision):
		emit_signal("projectileMissed")
	queue_free()
	
	
func nextTextIs(text: String) -> bool:
	return label.text.begins_with(text)
	
	
func _slowDown():
	$Tween.interpolate_property(
		self, 'speed', 
		null, 0.0, 
		0.1, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()
