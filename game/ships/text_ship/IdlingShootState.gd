extends IdlingState
class_name IdlingShootState
"""
Hover state where the ship shoots part of its letters out towards
the bottom ship as a projectile
"""
const ProjectileScn = preload("res://ships/shooter/Projectile.tscn")

export(float) var projectileSpeed: float = 150
export(float) var idleTimeInShooting: float = 1.6



func processState(delta: float):
	.processState(delta)

	
func enterState(prevState: String):
	.enterState(prevState)
	entity.anim.play("shoot")
	remainingIdleTime = idleTimeInShooting
	
	
func exitState(nextState: String):
	.exitState(nextState)
	
	
func performShot():
	var projectile = ProjectileScn.instance()
	projectile.global_position = entity.projectilePosition.global_position
	projectile.fireDirection = entity.global_position.direction_to(G.shooterShip.global_position)
	projectile.speed = projectileSpeed
	G.currentScene.add_child(projectile)
	var useNumLetters = randi() % 3 + 1
	projectile.label.text = entity.currentText.substr(0, useNumLetters)
	entity.currentText = entity.currentText.substr(useNumLetters)
