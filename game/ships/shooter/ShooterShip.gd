extends Node2D
"""
Controller for ship that shoots projectiles 
while player is typing for the illusion of a dogfight
"""
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
onready var fsm: StateMachine = $ShooterShipStateMachine


var chamber: String = ""
var shipHit = false


func _ready():
	emptyChamber()
	
	
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
