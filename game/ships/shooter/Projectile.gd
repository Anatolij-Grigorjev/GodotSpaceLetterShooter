extends Node2D
"""
Controller for non-homing forward facing projectile
"""


export(float) var speed: float = 750.6
export(float) var angularVelocity: float = 6

var fireDirection: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	rotation_degrees += angularVelocity
	var velocity = fireDirection * speed
	position += (velocity * delta)



func _on_Area2D_area_entered(area: Area2D):
	queue_free()
