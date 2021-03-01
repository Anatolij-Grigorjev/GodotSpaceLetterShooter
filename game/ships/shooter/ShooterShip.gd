extends Node2D
"""
Controller for ship that shoots projectiles 
while player is typing for the illusion of a dogfight
"""

export(PackedScene) var projectileScene: PackedScene

onready var shotPosition: Position2D = $Sprite/ShotPosition
onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	pass # Replace with function body.
	
	
func faceTextShip(letter: String, ship: TextShip) -> void:
	rotation = global_position.angle_to(ship.global_position)
	anim.play("shoot")
	fireShot(ship)


func fireShot(ship: TextShip) -> void:
	var projectile = projectileScene.instance()
	projectile.global_position = shotPosition.global_position
	projectile.fireDirection = global_position.direction_to(ship.global_position)
	get_parent().add_child(projectile)
