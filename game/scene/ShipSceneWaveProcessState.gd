extends State
class_name ShipSceneWaveProcessState
"""
State to hold and use logic of ongoing wave in scene
"""


var liveWaveShips: int = 0
var waveOver: bool = false
var shooterFailed: bool = false


func enterState(prevState: String):
	.enterState(prevState)
	var shipsContainer = entity.get_node("TextShips")
	liveWaveShips = shipsContainer.get_child_count()
	for ship in shipsContainer.get_children():
		_registerShipHandlers(ship)
		
		
func exitState(nextState: String):
	.exitState(nextState)
	var stateNode = fsm.getState(nextState)
	stateNode.shooterFailed = shooterFailed


func _registerShipHandlers(ship: TextShip) -> void:
	Stats.connectTextShipStatsSignals(ship)
	Utils.tryConnect(ship, "textShipCollidedShooter", self, "_onShooterCollided")
	Utils.tryConnect(ship, "textShipDestroyed", self, "_countDestroyedShip")
	Utils.tryConnect(ship, "shotFired", self, "_onShipShotFired")
	
	
func _onShooterCollided():
	waveOver = true
	shooterFailed = true
	
	
func _countDestroyedShip(shipText: String):
	liveWaveShips -= 1
	waveOver = liveWaveShips <= 0
		
		
func _onShipShotFired(projectile: Node2D):
	entity.add_child(projectile)
	#dont count enemy projectiles towards player stats
	if (not projectile.is_in_group("shootable-projectile")):
		Stats.connectProjectileStatsSignals(projectile)
		
		
func _input(event: InputEvent) -> void:
	if (not event is InputEventKey):
		return
	var keyEvent: InputEventKey = event as InputEventKey
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = OS.get_scancode_string(keyEvent.scancode)
	
	var specialCodeToggles := _checkSpecialCodes(keyCharCode)
	
	if (keyCharCode.length() == 1):
		entity.emit_signal("letterTyped", keyCharCode)

	var shootableWithLetter: Node2D = _findShootableWithNextText(entity.shooter.chamber)
	if (is_instance_valid(shootableWithLetter)):
		entity.shooter.faceShootable(shootableWithLetter)
	if (specialCodeToggles.fireChambered):
		entity.shooter.tryFireAt(shootableWithLetter)
	

func _isKeyJustPressed(keyEvent: InputEventKey) -> bool:
	return not keyEvent.echo and keyEvent.pressed
	

func _findShootableWithNextText(text: String) -> Node2D:
	if (text.empty()):
		return null
	var foundProjectile := _findWithTextInGroup(text, "shootable-projectile")
	if (is_instance_valid(foundProjectile)):
		return foundProjectile
	var foundShip := _findWithTextInGroup(text, "shootable-ship")
	if (is_instance_valid(foundShip)):
		return foundShip
	return null


func _findWithTextInGroup(text: String, group: String) -> Node2D:
	for node in get_tree().get_nodes_in_group(group):
		if (node.nextTextIs(text)):
			return node
	return null
	
	
func _checkSpecialCodes(keyCode: String) -> Dictionary:
	return {
		'fireChambered': keyCode == "Space"
	}
