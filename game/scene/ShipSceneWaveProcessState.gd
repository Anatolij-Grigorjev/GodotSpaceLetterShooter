extends State
class_name ShipSceneWaveProcessState
"""
State to hold and use logic of ongoing wave in scene
"""
var liveWaveShips: int = 0
var waveOver: bool = false
var latestKeyInputEvent: InputEventKey

var latestSpecialCodeToggles: Dictionary = {
		'fireChambered': false
}


func enterState(prevState: String):
	.enterState(prevState)
	waveOver = false
	latestKeyInputEvent = null
	var shipsContainer = entity.textShipsContainer
	var shipsNodes = Utils.getNodeChildrenInGroup(shipsContainer, "text_ship")
	liveWaveShips = shipsNodes.size()
	for ship in shipsNodes:
		_registerShipHandlers(ship)
		
		
func processState(delta: float):
	.processState(delta)
	if (latestKeyInputEvent):
		_processLatestKey()
	
		
		
func exitState(nextState: String):
	.exitState(nextState)
	waveOver = false


func _registerShipHandlers(ship: TextShip) -> void:
	Stats.connectTextShipStatsSignals(ship)
	Utils.tryConnect(ship, "textShipCollidedShooter", self, "_onShooterCollided")
	Utils.tryConnect(ship, "textShipReachedFinish", self, "_onShooterCollided")
	Utils.tryConnect(ship, "textShipDestroyed", self, "_countDestroyedShip")
	Utils.tryConnect(ship, "shotFired", fsm, "_onShipShotFired")
	
	
func _onShooterCollided():
	waveOver = true
	fsm.shooterFailed = true
	
	
func _countDestroyedShip(shipText: String):
	liveWaveShips -= 1
	waveOver = liveWaveShips <= 0
	


func _input(event: InputEvent) -> void:
	if (not event is InputEventKey):
		return
	latestKeyInputEvent = event as InputEventKey

		
func _processLatestKey() -> void:
	var keyEvent: InputEventKey = latestKeyInputEvent
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = OS.get_scancode_string(keyEvent.scancode)
	
	_updateSpecialCodeToggles(keyCharCode)
	
	if (keyCharCode.length() == 1):
		entity.emit_signal("letterTyped", keyCharCode)

	var shootableWithLetter: Node2D = _findShootableWithNextText(entity.shooter.chamber)
	_clearAllTargetedExcept(shootableWithLetter)
	if (is_instance_valid(shootableWithLetter)):
		entity.shooter.faceShootable(shootableWithLetter)
	if (latestSpecialCodeToggles.fireChambered):
		entity.emit_signal("fireCodeTyped", shootableWithLetter)
	latestKeyInputEvent = null
	

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
	
	
func _clearAllTargetedExcept(excludeShootable: Node2D):
	for node in (entity.textShipsContainer.get_children() + entity.get_children()):
		if (
			is_instance_valid(node)
			and "isTargeted" in node
		):
			if (node != excludeShootable):
				node.isTargeted = false


func _findWithTextInGroup(text: String, group: String) -> Node2D:
	for node in get_tree().get_nodes_in_group(group):
		if (node.nextTextIs(text)):
			return node
	return null
	

func _shootableIsShip(shootable: Node2D) -> bool:
	return shootable.get_groups().find("text_ship") != -1
	
	
func _updateSpecialCodeToggles(keyCode: String):
	latestSpecialCodeToggles.fireChambered = keyCode == "Space"
