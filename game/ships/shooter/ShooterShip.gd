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
	
	
func faceShootable(shootable: Node2D) -> void:
	var myPosition: Vector2 = global_position
	var shootablePosition: Vector2 = shootable.global_position
	
	var distanceToShip: float = (shootablePosition - myPosition).length()
	var verticalDiff: float = myPosition.y - shootablePosition.y
	var angleToShip = acos(verticalDiff / distanceToShip)
	var shootSide: int = Side.LEFT if myPosition.x > shootablePosition.x else Side.RIGHT
	rotation = angleToShip * shootSide


func fireChambered(shootable: Node2D) -> void:
	anim.play("shoot")
	var projectile = projectileScene.instance()
	projectile.global_position = shotPosition.global_position
	projectile.fireDirection = global_position.direction_to(shootable.global_position)
	# speed boost based on text size
	projectile.speed *= (1 + chamber.length() / 10)
	G.currentScene.add_child(projectile)
	projectile.label.text = chamber
	emptyChamber()
	
	
func missFire():
	anim.play("jam")
	emptyChamber()
	
	
func emptyChamber():
	chamber = ""
	emit_signal("shotFired")
	
	
func roundChambered() -> bool:
	return not chamber.empty()


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		emptyChamber()
