extends State
class_name ShooterShipShootingState
"""
actions related to shooting ship doing the shooting
"""

export(float) var maxDuration := 0.5

var shootingDone: bool = false
var shotTarget
var stateTimeout: Timer

func _ready():
	_attachTimeoutTimer()
	yield(get_tree(), "idle_frame")
	Utils.tryConnect(entity.anim, "animation_finished", self, "_entityFinishedShotAnimation")


func enterState(prevState: String):
	.enterState(prevState)
	stateTimeout.start()
	shootingDone = false
	tryFireAt(shotTarget)

	
	
func exitState(nextState: String):
	.exitState(nextState)
	stateTimeout.stop()
	#explicitly unset parameters controleld by animation
	# animation might have been interrupted by a hit state
	entity.sprite.position = Vector2.ZERO
	entity.shotPosition.get_node('ShotSprite').visible = false
	shootingDone = true
	shotTarget = null
	
	
	
func tryFireAt(target):
	if (not entity.chamber.empty()):
		fireChambered(target)
		if is_instance_valid(target) and "isTargeted" in target:
			target.lockTarget()
	else:
		missFire()


func fireChambered(shootable):
	entity.anim.play("shoot")
	var projectile = entity.projectileScene.instance()
	projectile.global_position = entity.shotPosition.global_position
	if is_instance_valid(shootable):
		projectile.fireDirection = entity.global_position.direction_to(shootable.global_position)
	else:
		#if no target shoot in current direction
		projectile.fireDirection = entity.global_position.direction_to(entity.shotPosition.global_position)
	_configureShooterShipProjectile(projectile)
	projectile.get_node("Label").text = entity.chamber
	entity.emit_signal("shotFired", projectile)
	entity.emptyChamber()
	
	
func missFire():
	entity.anim.play("jam")
	entity.emptyChamber()
	
	
func _entityFinishedShotAnimation(animationName: String):
	shootingDone = animationName in ["jam", "shoot"] or not isActive
	
	
func _configureShooterShipProjectile(projectile: Node2D):
	projectile.get_node("Sprite").modulate = Color.lightblue
	projectile.get_node("RigidBody2D").collision_mask = entity.projectileCollisionMask
	projectile.get_node("RigidBody2D").collision_layer = 0


func _attachTimeoutTimer():
	stateTimeout = Timer.new()
	stateTimeout.wait_time = maxDuration
	stateTimeout.one_shot = true
	add_child(stateTimeout)
	Utils.tryConnect(stateTimeout, "timeout", self, "_onStateTimeout")
	stateTimeout.stop()
	

func _onStateTimeout():
	if isActive:
		shootingDone = true
