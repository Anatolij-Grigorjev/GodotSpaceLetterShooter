extends Node2D
"""
Controller for non-homing forward facing projectile
"""
signal projectileDestroyed(text)
signal projectileMissed

export(float) var speed: float = 1050.77
export(float) var angularVelocity: float = 6
export(bool) var isTargeted: bool = false setget _setAsTarget

var fireDirection: Vector2 = Vector2.ZERO

onready var sprite: Sprite = $Sprite
onready var label: Label = $Label
onready var area: Area2D = $Area2D


var hadCollision: bool = false
	


func _process(delta):
	sprite.rotation_degrees += angularVelocity
	var velocity = fireDirection * speed
	position += (velocity * delta)



func _on_Area2D_area_entered(area: Area2D):
	hadCollision = true
	var areaOwner: Node2D = area.get_parent()
	if (
		areaOwner.is_in_group("projectile")
		or areaOwner.is_in_group("bubble")
	):
		speed = 0.0
		emit_signal("projectileDestroyed", getText())
	$AnimationPlayer.play("collide")


func _on_VisibilityNotifier2D_screen_exited():
	#event also fired during collision animation, so need to avoid counting that
	if (not hadCollision):
		emit_signal("projectileMissed")
	queue_free()
	
	
func nextTextIs(text: String) -> bool:
	return getText().begins_with(text)
	
	
func getText() -> String:
	return label.text if is_instance_valid(label) else ""
	
	
func lockTarget():
	$Sprite/Target.lockout()
	isTargeted = false
	
	
func _slowDown():
	$Tween.interpolate_property(
		self, 'speed', 
		null, 0.0, 
		0.1, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()
	
	
func _setAsTarget(isTarget: bool):
	isTargeted = isTarget
	if (
		$Sprite/Target 
		and isTargeted
		and not $Sprite/Target.visible
	):
		$Sprite/Target.lockin()
		_animateTargetIfInputTextExactMatch()
	elif ($Sprite/Target and $Sprite/Target.visible):
		$Sprite/Target.lockout()
			
			
func _pulseTarget(letter: String):
	$Sprite/Target.pulse()
	_animateTargetIfInputTextExactMatch()
		
		
func _animateTargetIfInputTextExactMatch():
	var inputText: String = get_tree().get_nodes_in_group("input")[0].label.text
	if (inputText == getText()):
		$Sprite/Target.anim.play("exact_match")
