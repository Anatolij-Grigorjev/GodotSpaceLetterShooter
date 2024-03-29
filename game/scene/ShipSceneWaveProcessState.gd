extends State
class_name ShipSceneWaveProcessState
"""
State to hold and use logic of ongoing wave in scene
"""
const INPUT_BUFFER = 7

var liveWaveShips: int = 0
var waveOver: bool = false
var numAddedInputEvents = 0
var latestKeyInputEvents: Array

var latestSpecialCodeToggles: Dictionary = {
		'fireChambered': false
}


func _ready():
	latestKeyInputEvents = []
	latestKeyInputEvents.resize(INPUT_BUFFER)


func enterState(prevState: String):
	.enterState(prevState)
	waveOver = false
	numAddedInputEvents = 0
	var shipsContainer = entity.textShipsContainer
	var shipsNodes = Utils.getNodeChildrenInGroup(shipsContainer, "text_ship")
	liveWaveShips = shipsNodes.size()
	for ship in shipsNodes:
		_registerShipHandlers(ship)
		

func _input(event: InputEvent) -> void:
	if (not event is InputEventKey):
		return
	if numAddedInputEvents < INPUT_BUFFER:
		latestKeyInputEvents[numAddedInputEvents] = event as InputEventKey
		numAddedInputEvents += 1
		
		
func processState(delta: float):
	.processState(delta)
	if (numAddedInputEvents > 0):
		for idx in range(numAddedInputEvents):
			_processLatestKey(latestKeyInputEvents[idx])
		numAddedInputEvents = 0
	
		
		
func exitState(nextState: String):
	.exitState(nextState)
	waveOver = false


func _registerShipHandlers(ship: TextShip) -> void:
	Stats.connectTextShipStatsSignals(ship)
	Utils.tryConnect(ship, "textShipCollidedShooter", self, "_onShooterCollided")
	Utils.tryConnect(ship, "textShipReachedFinish", self, "_onShooterCollided")
	Utils.tryConnect(ship, "textShipDestroyed", self, "_countDestroyedShip")
	Utils.tryConnect(ship, "shotFired", fsm, "_onShipShotFired")
	Utils.tryConnect(ship, "shipDroppedLetter", fsm, "_onShipDroppedLetter")
	
	
func _onShooterCollided():
	waveOver = true
	fsm.shooterFailed = true
	
	
func _countDestroyedShip(shipText: String):
	liveWaveShips -= 1
	waveOver = liveWaveShips <= 0
	
		

		
func _processLatestKey(keyEvent: InputEventKey) -> void:
	if (not _isKeyJustPressed(keyEvent)):
		return
	var keyCharCode: String = _getInputEventKeyCode(keyEvent)
	
	_updateSpecialCodeToggles(keyCharCode)
	
	if (keyCharCode.length() == 1):
		entity.emit_signal("letterTyped", keyCharCode)

	var shootableWithLetter: Node2D = _findShootableWithNextText(entity.shooter.chamber)
	_clearAllTargetedExcept(shootableWithLetter)
	if (is_instance_valid(shootableWithLetter)):
		entity.shooter.faceShootable(shootableWithLetter)
	if (latestSpecialCodeToggles.fireChambered):
		entity.emit_signal("fireCodeTyped", shootableWithLetter)
	

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
	
	
func _keyCodeIsFireToggle(keyCode: String) -> bool:
	return keyCode == "Space"
	
	
func _getInputEventKeyCode(event: InputEventKey) -> String:
	return OS.get_scancode_string(event.scancode)
	
	
func _updateSpecialCodeToggles(keyCode: String):
	latestSpecialCodeToggles.fireChambered = _keyCodeIsFireToggle(keyCode) 
