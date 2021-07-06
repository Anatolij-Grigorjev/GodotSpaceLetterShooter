extends Node2D
"""
Controller for ship that shoots projectiles 
while player is typing for the illusion of a dogfight
"""
const SpokeScn = preload("res://ships/shooter/VisibleSpoke.tscn")

const ROTATE_RADS_PER_SEC = 3

enum Side {
	LEFT = -1,
	RIGHT = 1
}

signal shotFired(projectile)
signal chamberEmptied
signal shooterHitByShot(projectile)
signal hyperspeedToggled

export(PackedScene) var projectileScene: PackedScene
export(int, LAYERS_2D_PHYSICS) var projectileCollisionMask: int = 0

onready var shotPosition: Position2D = $Sprite/ShotPosition
onready var anim: AnimationPlayer = $AnimationPlayer
onready var tween: Tween = $Tween


var chamber: String = ""


func _ready():
	emptyChamber()
	
	
func chamberLetter(letter: String):
	chamber += letter
	
	
func addSpoke(letter: String):
	var spoke = SpokeScn.instance()
	spoke.allowedRotationRange = Vector2(150, 210)
	spoke.scale = Vector2(0.1, 3)
	spoke.offset = Vector2(0, 50)
	spoke.visible = false
	
	$Sprite.add_child(spoke)
	spoke.showSpoke()
	
	
func faceShootable(shootable: Node2D) -> void:
	var myPosition: Vector2 = global_position
	var shootablePosition: Vector2 = shootable.global_position
	
	var distanceToShip: float = (shootablePosition - myPosition).length()
	var verticalDiff: float = myPosition.y - shootablePosition.y
	var angleToShip = acos(verticalDiff / distanceToShip)
	var shootSide: int = Side.LEFT if myPosition.x > shootablePosition.x else Side.RIGHT
	rotation = angleToShip * shootSide
	
	if "isTargeted" in shootable:
		shootable.isTargeted = true
	
	
func tryFireAt(target: Node2D):
	if (not chamber.empty() and is_instance_valid(target)):
		fireChambered(target)
		if "isTargeted" in target:
			target.lockTarget()
	else:
		missFire()


func fireChambered(shootable: Node2D) -> void:
	anim.play("shoot")
	var projectile = projectileScene.instance()
	projectile.global_position = shotPosition.global_position
	projectile.fireDirection = global_position.direction_to(shootable.global_position)
	_configureShooterShipProjectile(projectile)
	projectile.get_node("Label").text = chamber
	emit_signal("shotFired", projectile)
	emptyChamber()
	
	
func missFire():
	anim.play("jam")
	emptyChamber()
	
	
func emptyChamber():
	chamber = ""
	emit_signal("chamberEmptied")
	
	
func resetRotationTween():
	tween.interpolate_property(
		self, "rotation", 
		null, 0.0, abs(rotation) / ROTATE_RADS_PER_SEC, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()
	yield(tween, "tween_all_completed")
	tween.remove_all()


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		emit_signal("shooterHitByShot", areaOwner)
		anim.play("hit")
		emptyChamber()
	
		
		
func _configureShooterShipProjectile(projectile: Node2D):
	projectile.get_node("Sprite").modulate = Color.lightblue
	projectile.get_node("Area2D").collision_mask = projectileCollisionMask
	projectile.get_node("Area2D").collision_layer = 0
