extends Node2D
"""
Controller for ship that shoots projectiles 
while player is typing for the illusion of a dogfight
"""
enum Side {
	LEFT = -1,
	RIGHT = 1
}

signal shotFired(projectile)
signal chamberEmptied
signal shooterHitByShot(projectile)
signal hyperSpeedToggled(speedUp)

export(PackedScene) var projectileScene: PackedScene
export(int, LAYERS_2D_PHYSICS) var projectileCollisionMask: int = 0

onready var shotPosition: Position2D = $Sprite/ShotPosition
onready var anim: AnimationPlayer = $AnimationPlayer
onready var tween: Tween = $Tween
onready var sprite: AnimatedSprite = $Sprite
onready var fsm: StateMachine = $ShooterShipStateMachine
onready var invincibilityTimer: Timer = $InvincibilityTimer
onready var bodyArea: RigidBody2D = $RigidBody2D


var chamber: String = ""
var shipHit = false


func _ready():
	emptyChamber()
	
	
func startNextWave():
	if (fsm.state == StateMachine.NO_STATE):
		fsm.state = "StartingFirstWave"
	else:
		fsm.state = "StartingNextWave"
	
	
func faceShootable(shootable: Node2D):
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
	
	
func _shipToggledHyperSpeed():
	emit_signal("hyperSpeedToggled", fsm.state == "LeavingWave")
	
	
func bodyCollider() -> CollisionShape2D:
	return bodyArea.get_node("CollisionShape2D") as CollisionShape2D
