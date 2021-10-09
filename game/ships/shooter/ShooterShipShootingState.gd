extends State
class_name ShooterShipShootingState
"""
actions related to shooting ship doing the shooting
"""

var shootingDone: bool = false
var shotTarget


func enterState(prevState: String):
	print("Enter function enterState...")
	.enterState(prevState)
	shootingDone = false
	yield(tryFireAt(shotTarget), "completed")
	print("Exit function enterState...")

	
	
func exitState(nextState: String):
	print("Enter function exitState...")
	.exitState(nextState)
	#explicitly unset parameters controleld by animation
	# animation might have been interrupted by a hit state
	entity.sprite.position = Vector2.ZERO
	entity.shotPosition.get_node('ShotSprite').visible = false
	shootingDone = true
	shotTarget = null
	print("Exit function exitState...")
	
	
	
func tryFireAt(target):
	print("Enter function tryFireAt...")
	if (not entity.chamber.empty() and is_instance_valid(target)):
		fireChambered(target)
		if "isTargeted" in target:
			target.lockTarget()
	else:
		missFire()
	if (entity.anim.is_playing()):
		yield(entity.anim, "animation_finished")
	shootingDone = true
	print("Exit function tryFireAt...")


func fireChambered(shootable):
	print("Enter function fireChambered...")
	entity.anim.play("shoot")
	var projectile = entity.projectileScene.instance()
	projectile.global_position = entity.shotPosition.global_position
	projectile.fireDirection = entity.global_position.direction_to(shootable.global_position)
	_configureShooterShipProjectile(projectile)
	projectile.get_node("Label").text = entity.chamber
	entity.emit_signal("shotFired", projectile)
	entity.emptyChamber()
	print("Exit function fireChambered...")
	
	
func missFire():
	print("Enter function missFire...")
	entity.anim.play("jam")
	entity.emptyChamber()
	print("Exit function missFire...")
	
	
func _configureShooterShipProjectile(projectile: Node2D):
	print("Enter function _configureShooterShipProjectile...")
	projectile.get_node("Sprite").modulate = Color.lightblue
	projectile.get_node("Area2D").collision_mask = entity.projectileCollisionMask
	projectile.get_node("Area2D").collision_layer = 0
	print("Exit function _configureShooterShipProjectile...")
