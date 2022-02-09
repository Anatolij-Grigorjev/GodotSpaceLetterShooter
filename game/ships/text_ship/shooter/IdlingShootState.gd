extends IdlingState
class_name IdlingShootState
"""
Hover state where the ship shoots part of its letters out towards
the bottom ship as a projectile
"""
signal textShipLettersShot(lettersLeft)

export(NodePath) var projectileSpawnPositionNodePath
export(PackedScene) var projectileScn
export(int, LAYERS_2D_PHYSICS) var projectileCollisionMask: int = 0
export(float) var projectileSpeed: float = 150

onready var projectileSpawnPositionNode = get_node(projectileSpawnPositionNodePath)

	
func enterState(prevState: String):
	.enterState(prevState)
	entity.anim.play("shoot")
	
	
func performShot():
	var projectile = projectileScn.instance()
	_configureTextShipProjectile(projectile)
	
	var useNumLetters = _getNumAllowedProjectileLetters()
	projectile.get_node("Label").text = entity.currentText.substr(0, useNumLetters)
	entity.currentText = entity.currentText.substr(useNumLetters)
	
	entity.emit_signal("shotFired", projectile)
	emit_signal("textShipLettersShot", entity.currentText.length())


func _configureTextShipProjectile(projectile: Node2D):
	var shooterShip: Node2D = Utils.getFirstTreeNodeInGroup(get_tree(), "shooter")
	projectile.global_position = projectileSpawnPositionNode.global_position
	projectile.fireDirection = entity.global_position.direction_to(shooterShip.global_position)
	projectile.speed = projectileSpeed
	projectile.get_node("Sprite").modulate = Color.lightpink
	projectile.get_node("RigidBody2D").collision_mask = projectileCollisionMask
	projectile.get_node("RigidBody2D").collision_layer = entity.get_node("RigidBody2D").collision_layer
	projectile.add_to_group("shootable-projectile")
	
	
func _getNumAllowedProjectileLetters() -> int:
	var expectedRange: NumRange = fsm.lettersPerShotRange
	var expectedNum = expectedRange.random()
	
	return int(clamp(expectedNum, expectedRange.minVal, entity.currentText.length() - 1))
	
