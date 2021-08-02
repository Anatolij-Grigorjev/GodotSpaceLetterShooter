extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
enum Direction {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3
}


signal letterTyped(letter)
signal fireCodeTyped(lockedTarget)


export(float) var screenScrollSpeed = 300
export(float) var endWaveWaitTime = 2.5
export(Direction) var shipDirection = Direction.DOWN setget setShipPosition

onready var shooter = $MovingElements/ShooterShip
onready var textShipsContainer = $MovingElements/TextShips
onready var camera = $MovingElements/Camera2D
onready var shaker = $MovingElements/Camera2D/ScreenShake
onready var freeze = $FreezeFrame
onready var animator = $AnimationPlayer
onready var playerInput = $CanvasLayer/PlayerInput
onready var musicControl = $CanvasLayer/MusicControl
onready var shipsFactory = $TextShipFactory
onready var fsm: ShipSceneStateMachine = $ShipSceneStateMachine
onready var tween: Tween = $ShipMovePositionsTween

var starsBG


var directionShipAngles = {
	Direction.UP: 180,
	Direction.DOWN: 0,
	Direction.LEFT: 90,
	Direction.RIGHT: 270
}
onready var directionPositions = {
	Direction.UP: $MovingElements/ShooterPositions/Top,
	Direction.DOWN: $MovingElements/ShooterPositions/Bottom,
	Direction.LEFT: $MovingElements/ShooterPositions/Left,
	Direction.RIGHT: $MovingElements/ShooterPositions/Right
}


func _ready():
	randomize()
	
	Utils.tryConnect(shooter, "shotFired", fsm, "_onShipShotFired")
	Utils.tryConnect(shooter, "chamberEmptied", playerInput, "clearText")
	Utils.tryConnect(shooter, "chamberEmptied", self, "_onShooterClearChamber")
	Utils.tryConnect(shooter, "hyperspeedToggled", self, "_onShooterToggleHyperspeed")
	Utils.tryConnect(shooter, "shooterHitByShot", self, "_onShooterHitByShot")
	
	call_deferred("_bindSceneStats")
	
	starsBG = Utils.getFirst(get_tree().get_nodes_in_group("bg"))
	
	
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
	shipDirection = clamp(newPosition, Direction.UP, Direction.RIGHT)
	shooter.position = directionPositions[shipDirection].position
	shooter.rotation_degrees = directionShipAngles[shipDirection]
	

func _bindSceneStats():
	Stats.currentScene = self
	
	
func _setAmountTravelAsDirectionVector(amount: float) -> Vector2:
	match(shipDirection):
		Direction.UP:
			return Vector2(0, amount)
		Direction.DOWN:
			return Vector2(0, -amount)
		Direction.LEFT:
			return Vector2(amount, 0)
		Direction.RIGHT:
			return Vector2(-amount, 0)
		_:
			breakpoint
			return Vector2.ZERO
	
	
func _onShooterClearChamber():
	for ship in textShipsContainer.get_children():
		ship.isTargeted = false
		
		
func _onTextShipHit(lettersRemaining: int):
	if lettersRemaining > 0:
		shaker.beginShake(0.2, 15, 10, 1)
		freeze.startFreeze(0.05)
	else:
		shaker.beginShake(0.2, 15, 20, 2)
		freeze.startFreeze(0.06)


func _onShooterHitByShot(projectile: Node2D):
	freeze.startFreeze(0.1)
	shaker.beginShake(0.75, 25, 25, 1)
		
		
func _onShooterToggleHyperspeed():
	var animator = _findBGAnimator()
	if (not animator):
		return
	var hyperSpeedAnimKey = "hyper_down"
	var hyperSpeedAnimation = animator.get_animation(hyperSpeedAnimKey)
	var waveEnded = fsm.state == "WaveEnd"
	if (waveEnded):
		#violent shake during acceleration of hyperness
		shaker.beginShake(hyperSpeedAnimation.length, 20, 25, 2)
		animator.play(hyperSpeedAnimKey)
		yield(animator, "animation_finished")
		var remainingFlyTime = max(0, shooter.anim.current_animation_length - hyperSpeedAnimation.length)
		#less violent shake for fly part
		shaker.beginShake(endWaveWaitTime + remainingFlyTime, 10, 15, 1)
	else:
		#quick non-violent shakes on deacceleration from hyperness
		shaker.beginShake(hyperSpeedAnimation.length, 20, 10, 2)
		animator.play("hyper_up")
		yield(animator, "animation_finished")
		# DOWN direction in background == 1
		starsBG.starsMoveDirection = 1
		


func _findBGAnimator() -> AnimationPlayer:
	var animator: AnimationPlayer = starsBG.get_node('AnimationPlayer')
	if (animator):
		return animator
	return null


func tweenShipToNewDirection(newDirection: int):
	tween.interpolate_property(
		shooter, 'position', 
		null, directionPositions[newDirection].position,
		1.0, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	tween.interpolate_property(
		shooter, 'rotation_degrees',
		null, directionShipAngles[newDirection],
		1.0, Tween.TRANS_EXPO, Tween.EASE_IN
	)
	tween.start()
	yield(tween, "tween_all_completed")
	setShipPosition(newDirection)
