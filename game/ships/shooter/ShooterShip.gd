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
	var myPosition: Vector2 = global_position; var shipPosition: Vector2 = ship.global_position
	
	var distanceToShip: float = (shipPosition - myPosition).length()
	var verticalDiff: float = myPosition.y - shipPosition.y
	var angleToShip = acos(verticalDiff / distanceToShip)
	var shipSide: int = Side.LEFT if myPosition.x > shipPosition.x else Side.RIGHT
	rotation = angleToShip * shipSide
	anim.play("shoot")
	fireShot(letter, ship)


func fireShot(letter: String, ship: TextShip) -> void:
	var projectile = projectileScene.instance()
	projectile.global_position = shotPosition.global_position
	projectile.fireDirection = global_position.direction_to(ship.global_position)
	get_parent().add_child(projectile)
	projectile.label.text = letter
