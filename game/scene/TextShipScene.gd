extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal sceneCleared(sceneSpecId)
signal sceneFailed(sceneSpecId)
signal letterTyped(letter)


export(float) var screenScrollSpeed = 300
export(float) var endWaveWaitTime = 2.5


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
onready var stateLabel: Label = $CanvasLayer/StateLabel


func _ready():
	randomize()
	Utils.tryConnect(fsm, "stateChanged", self, "_fsmStateChanged")
	call_deferred("_bindSceneStats")
	
	
func _process(delta: float):
	var screenTravel = delta * screenScrollSpeed
	$MovingElements.position.y -= screenTravel
	for projectileNode in get_tree().get_nodes_in_group("projectile"):
		if (is_instance_valid(projectileNode)):
			projectileNode.position.y -= screenTravel
		
	

func setSceneSpecificaion(spec: SceneSpec):
	$TextShipFactory.setShipsWordsCorpusPath(spec.wordsCorpusPath)
	get_node("ShipSceneStateMachine").sceneSpecification = spec
	

func _bindSceneStats():
	Stats.currentScene = self
	
	
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
	var hyperSpeedAnimKey = "hyper"
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
		#non-violent shake on deacceleration from hyperness
		shaker.beginShake(hyperSpeedAnimation.length, 10, 15, 2)
		animator.play_backwards(hyperSpeedAnimKey)


func _findBGAnimator() -> AnimationPlayer:
	var currentSceneBGNode = Utils.getFirst(get_tree().get_nodes_in_group("bg"))
	if (is_instance_valid(currentSceneBGNode)):
		var animator: AnimationPlayer = currentSceneBGNode.get_node('AnimationPlayer')
		if (animator):
			return animator
	return null
	
	

func _fsmStateChanged(oldState: String, newState: String):
	stateLabel.text = "state: [%s] -> [%s]" % [oldState, newState]
