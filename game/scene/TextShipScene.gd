extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
const FloatingPointsScn = preload("res://scene/gui/FloatingPoints.tscn")  

enum Direction {
	TOP = 0,
	BOTTOM = 1,
	LEFT = 2,
	RIGHT = 3
}


signal letterTyped(letter)
signal fireCodeTyped(lockedTarget)


export(float) var screenScrollSpeed = 300
export(float) var endWaveWaitTime = 2.5
export(Direction) var shipDirection = Direction.BOTTOM setget setShipPosition

onready var shooter = $MovingElements/ShooterShip
onready var textShipsContainer = $MovingElements/TextShips
onready var camera = $MovingElements/Camera2D
onready var shaker = $MovingElements/Camera2D/CameraShake
onready var freeze = $FreezeFrame
onready var animator = $AnimationPlayer

onready var playerInput = $CanvasLayer/PlayerInput
onready var musicControl = $CanvasLayer/MusicControl
onready var totalScore = $CanvasLayer/TotalRunningScore
onready var cinematicBars = $CanvasLayer/CinematicBars

onready var shipsFactory = $TextShipFactory
onready var fsm: ShipSceneStateMachine = $ShipSceneStateMachine
onready var tween: Tween = $ShipMovePositionsTween

var sceneBG


var directionShipAngles = {
	Direction.TOP: 180,
	Direction.BOTTOM: 0,
	Direction.LEFT: 90,
	Direction.RIGHT: 270
}
onready var directionPositions = {
	Direction.TOP: $MovingElements/ShooterPositions/Top,
	Direction.BOTTOM: $MovingElements/ShooterPositions/Bottom,
	Direction.LEFT: $MovingElements/ShooterPositions/Left,
	Direction.RIGHT: $MovingElements/ShooterPositions/Right
}


func _ready():
	randomize()
	
	totalScore.totalScore = GameConfig.totalShooterScore
	
	sceneBG = Utils.getFirst(get_tree().get_nodes_in_group("bg"))
	
	Utils.tryConnect(shooter, "shotFired", fsm, "_onShipShotFired")
	Utils.tryConnect(shooter, "chamberEmptied", playerInput, "clearText")
	Utils.tryConnect(shooter, "shotFired", playerInput, "flashInput")
	Utils.tryConnect(shooter, "chamberEmptied", self, "_onShooterClearChamber")
	Utils.tryConnect(shooter, "hyperSpeedToggled", self, "_onShooterToggleHyperspeed")
	Utils.tryConnect(shooter, "shooterHitByShot", self, "_onShooterHitByShot")
	Utils.tryConnect(sceneBG, "bgWillHaveTurned", self, "_scheduleShooterTurning")
	
	call_deferred("_bindSceneStats")
	
	#running standalone, make mock scene spec
	if Scenes.activeScene == null:
		var shipPosition = Direction.BOTTOM
		setShipPosition(shipDirection)
		sceneBG.starsMoveDirection = shipDirection
		setSceneSpecificaion(Mock.sceneShipTypeQuantities(1, 1, 1))
	
	#small objects layer is offset by engine???
	sceneBG.smallObjectsLayer.motion_offset.x = 400
	
	
	
func _process(delta: float):
	var screenTravelAmount = delta * screenScrollSpeed
	var screenTravel := _setAmountTravelAsDirectionVector(screenTravelAmount)
	$MovingElements.position += screenTravel
	for projectileNode in get_tree().get_nodes_in_group("projectile"):
		if (is_instance_valid(projectileNode)):
			projectileNode.position += screenTravel
		
	

func setSceneSpecificaion(spec: SceneSpec):
	$TextShipFactory.setShipsWordsCorpusPath(spec.wordsCorpusPath)
	get_node("ShipSceneStateMachine").sceneSpecification = spec
	
	
func setShipPosition(newPosition: int):
	shipDirection = clamp(newPosition, Direction.TOP, Direction.RIGHT)
	shooter.position = directionPositions[shipDirection].position
	shooter.rotation_degrees = directionShipAngles[shipDirection]
	

func _bindSceneStats():
	Stats.currentScene = self
	
	
func _setAmountTravelAsDirectionVector(amount: float) -> Vector2:
	match(shipDirection):
		Direction.TOP:
			return Vector2(0, -amount)
		Direction.BOTTOM:
			return Vector2(0, -amount)
		Direction.LEFT:
			return Vector2(-amount, 0)
		Direction.RIGHT:
			return Vector2(-amount, 0)
		_:
			breakpoint
			return Vector2.ZERO
	
	
func _onShooterClearChamber():
	_clearAllTargeted()
	
	
func _clearAllTargeted():
	for node in textShipsContainer.get_children():
		if is_instance_valid(node) and "isTargeted" in node:
			node.isTargeted = false

		
		
func _onTextShipHit(lettersRemaining: int):
	if lettersRemaining > 0:
		_doMinorHitScreenFX()
	else:
		_doMajorHitScreenFX()
		
		
func _doMinorHitScreenFX():
	shaker.beginShake(0.2, 15, 10, 1)
	freeze.startFreeze(0.05)
	Blinker.blink(Color.darkred, 0.05)
	

func _doMajorHitScreenFX():
	shaker.beginShake(0.2, 15, 20, 2)
	freeze.startFreeze(0.06)


func _onShooterHitByShot(projectile: Node2D):
	freeze.startFreeze(0.1)
	shaker.beginShake(0.75, 25, 25, 1)
	_clearAllTargeted()
	
	
		
func _onShooterToggleHyperspeed(speedUp: bool):
	var shipTurnDisabled = not fsm.sceneSpecification.shooterTurnsBetweenWaves
	if shipTurnDisabled and speedUp:
		sceneBG.startHyperNoTurn()
		return
	
	var waveEnded = fsm.state == "WaveEnd"
	var sceneEnded = waveEnded and fsm.remainingSceneShips <= 0
	if (waveEnded and not sceneEnded):
		sceneBG.startHyperTurn()
	elif (sceneEnded):
		sceneBG.startHyper()
		
		
func _onTextShipPointsEarned(numPoints: int, shipPosition: Vector2):
	
	totalScore.addPoints(numPoints)
	
	var floatingPointsNode: Node = _createFloatingPointsNode(numPoints)
	$CanvasLayer.add_child(floatingPointsNode)
	floatingPointsNode.rect_position = shipPosition



func _createFloatingPointsNode(numPoints: int) -> Node:
	var floatingPointsNode := FloatingPointsScn.instance()
	floatingPointsNode.get_node("Label").text = "+%03d" % numPoints
	
	return floatingPointsNode

	
	
func _scheduleShooterTurning(direction: int, time: float):
	if (time > 1.0):
		yield(get_tree().create_timer(time - 1.0), "timeout")
	tweenShipToNewDirection(direction)


func tweenShipToNewDirection(newDirection: int):
	tween.interpolate_property(
		shooter, 'position', 
		null, directionPositions[newDirection].position,
		1.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		shooter, 'rotation_degrees',
		null, directionShipAngles[newDirection],
		1.0, Tween.TRANS_EXPO, Tween.EASE_OUT_IN
	)
	tween.start()
	yield(tween, "tween_all_completed")
	setShipPosition(newDirection)
