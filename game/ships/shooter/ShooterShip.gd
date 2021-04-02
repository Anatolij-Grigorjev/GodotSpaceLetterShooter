extends Node2D
"""
Controller for ship that shoots projectiles 
while player is typing for the illusion of a dogfight
"""
enum Side {
	LEFT = -1,
	RIGHT = 1
}

signal shotFired

export(PackedScene) var projectileScene: PackedScene

onready var shotPosition: Position2D = $Sprite/ShotPosition
onready var anim: AnimationPlayer = $AnimationPlayer

var chamber: String = ""


func _ready():
	emptyChamber()
	G.shooterShip = self
	
	
func chamberLetter(letter: String):
	chamber += letter
	
	
func faceShip(ship: TextShip) -> void:
	var myPosition: Vector2 = global_position; var shipPosition: Vector2 = ship.global_position
	
	var distanceToShip: float = (shipPosition - myPosition).length()
	var verticalDiff: float = myPosition.y - shipPosition.y
	var angleToShip = acos(verticalDiff / distanceToShip)
	var shipSide: int = Side.LEFT if myPosition.x > shipPosition.x else Side.RIGHT
	rotation = angleToShip * shipSide


func fireChambered(ship: TextShip) -> void:
	anim.play("shoot")
	var projectile = projectileScene.instance()
	projectile.global_position = shotPosition.global_position
	projectile.fireDirection = global_position.direction_to(ship.global_position)
	# speed boost based on text size
	projectile.speed *= (1 + chamber.length() / 10)
	get_parent().add_child(projectile)
	projectile.label.text = chamber
	emptyChamber()
	
	
func missFire():
	anim.play("jam")
	emptyChamber()
	
	
func emptyChamber():
	chamber = ""
	emit_signal("shotFired")
