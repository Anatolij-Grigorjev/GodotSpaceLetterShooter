extends Node2D
"""
Controller for ship that shoots projectiles 
while player is typing for the illusion of a dogfight
"""
enum Side {
	LEFT = -1,
	RIGHT = 1
}

export(PackedScene) var projectileScene: PackedScene

onready var shotPosition: Position2D = $Sprite/ShotPosition
onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	pass # Replace with function body.
	
	
func faceAndShootTextShip(letter: String, ship: TextShip) -> void:
	var distanceToShip: float = (ship.global_position - global_position).length()
	var verticalDiff: float = global_position.y - ship.global_position.y
	var angleToShip = acos(verticalDiff / distanceToShip)
	var shipSide: int = Side.LEFT if global_position.x > ship.global_position.x else Side.RIGHT
	rotation = angleToShip * shipSide
	anim.play("shoot")
	fireShot(letter, ship)


func fireShot(letter: String, ship: TextShip) -> void:
	var projectile = projectileScene.instance()
	projectile.global_position = shotPosition.global_position
	projectile.fireDirection = global_position.direction_to(ship.global_position)
	get_parent().add_child(projectile)
	projectile.label.text = letter
