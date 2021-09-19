extends IdlingState
class_name IdlingShootState
"""
Hover state where the ship shoots part of its letters out towards
the bottom ship as a projectile
"""
signal shotLettersDepleted(lettersLeft)

export(NodePath) var projectileSpawnPositionNodePath
export(PackedScene) var projectileScn
export(int, LAYERS_2D_PHYSICS) var projectileCollisionMask: int = 0
export(float) var projectileSpeed: float = 150
export(int) var maxShotLettersLength: int = 2

onready var projectileSpawnPositionNode = get_node(projectileSpawnPositionNodePath)


func _ready():
	call_deferred("_checkCanShootAgain")


func processState(delta: float):
	.processState(delta)

	
func enterState(prevState: String):
	.enterState(prevState)
	entity.anim.play("shoot")
	
	
func exitState(nextState: String):
	.exitState(nextState)
	
	
func performShot():
	var projectile = projectileScn.instance()
	var shooterShip: Node2D = get_tree().get_nodes_in_group("shooter")[0]
	projectile.global_position = projectileSpawnPositionNode.global_position
	projectile.fireDirection = entity.global_position.direction_to(shooterShip.global_position)
	projectile.speed = projectileSpeed
	_configureTextShipProjectile(projectile)
	var useNumLetters = randi() % maxShotLettersLength + 1
	projectile.get_node("Label").text = entity.currentText.substr(0, useNumLetters)
	entity.currentText = entity.currentText.substr(useNumLetters)
	entity.emit_signal("shotFired", projectile)
	_checkCanShootAgain()
	

func _checkCanShootAgain():
	if (maxShotLettersLength >= entity.currentText.length()):
		emit_signal("shotLettersDepleted", entity.currentText.length())


func _configureTextShipProjectile(projectile: Node2D):
	projectile.get_node("Sprite").modulate = Color.lightpink
	projectile.get_node("Area2D").collision_mask = projectileCollisionMask
	projectile.get_node("Area2D").collision_layer = entity.get_node("Area2D").collision_layer
	projectile.add_to_group("shootable-projectile")
	
