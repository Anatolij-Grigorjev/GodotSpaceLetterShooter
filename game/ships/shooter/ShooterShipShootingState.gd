extends State
class_name ShooterShipShootingState
"""
actions related to shooting ship doing the shooting
"""

var shootingDone: bool = false
var shotTarget


func enterState(prevState: String):
	.enterState(prevState)
	shootingDone = false
	yield(tryFireAt(shotTarget), "completed")
	
	
func exitState(nextState: String):
	.exitState(nextState)
	shootingDone = true
	shotTarget = null
	
	
func tryFireAt(target: Node2D):
	if (not entity.chamber.empty() and is_instance_valid(target)):
		fireChambered(target)
		if "isTargeted" in target:
			target.lockTarget()
	else:
		missFire()
	yield(entity.anim, "animation_finished")
	shootingDone = true


func fireChambered(shootable: Node2D) -> void:
	entity.anim.play("shoot")
	var projectile = entity.projectileScene.instance()
	projectile.global_position = entity.shotPosition.global_position
	projectile.fireDirection = entity.global_position.direction_to(shootable.global_position)
	_configureShooterShipProjectile(projectile)
	projectile.get_node("Label").text = entity.chamber
	emit_signal("shotFired", projectile)
	entity.emptyChamber()
	
	
func missFire():
	entity.anim.play("jam")
	entity.emptyChamber()
	
	
func _configureShooterShipProjectile(projectile: Node2D):
	projectile.get_node("Sprite").modulate = Color.lightblue
	projectile.get_node("Area2D").collision_mask = entity.projectileCollisionMask
	projectile.get_node("Area2D").collision_layer = 0
