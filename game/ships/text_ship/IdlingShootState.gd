extends IdlingState
class_name IdlingShootState
"""
Hover state where the ship shoots part of its letters out towards
the bottom ship as a projectile
"""
signal shotLettersDepleted(lettersLeft)


export(PackedScene) var projectileScn
export(int, LAYERS_2D_PHYSICS) var projectileCollisionMask: int = 0
export(float) var projectileSpeed: float = 150
export(float) var idleTimeInShooting: float = 1.6
export(int) var maxShotLength: int = 2


func _ready():
	call_deferred("_checkCanShootAgain")


func processState(delta: float):
	.processState(delta)

	
func enterState(prevState: String):
	.enterState(prevState)
	entity.anim.play("shoot")
	remainingIdleTime = idleTimeInShooting
	
	
func exitState(nextState: String):
	.exitState(nextState)
	
	
func performShot():
	var projectile = projectileScn.instance()
	projectile.global_position = entity.projectilePosition.global_position
	projectile.fireDirection = entity.global_position.direction_to(G.shooterShip.global_position)
	projectile.speed = projectileSpeed
	_configureTextShipProjectile(projectile)
	G.currentScene.add_child(projectile)
	var useNumLetters = randi() % maxShotLength + 1
	G.currentSceneStats.totalProjectilesLetters += useNumLetters
	projectile.label.text = entity.currentText.substr(0, useNumLetters)
	entity.currentText = entity.currentText.substr(useNumLetters)
	_checkCanShootAgain()
	

func _checkCanShootAgain():
	if (maxShotLength >= entity.currentText.length()):
		emit_signal("shotLettersDepleted", entity.currentText.length())


func _configureTextShipProjectile(projectile: Node2D):
	projectile.get_node("Sprite").modulate = Color.lightpink
	projectile.get_node("Area2D").collision_mask = projectileCollisionMask
	projectile.get_node("Area2D").collision_layer = entity.get_node("Area2D").collision_layer
	projectile.add_to_group("shootable-projectile")
	G.connectProjectileStatsSignals(projectile)
	
