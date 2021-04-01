extends Node2D



onready var anim: AnimationPlayer = $AnimationPlayer

var bubbleHit: bool = false

func _ready():
	pass


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		var collideProjectile = areaOwner
		bubbleHit = true
		anim.play("hit")
		yield(anim, "animation_finished")
		bubbleHit = false
		
		
