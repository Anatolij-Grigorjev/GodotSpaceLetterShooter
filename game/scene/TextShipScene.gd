extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal sceneCleared(sceneSpecId)
signal sceneFailed(sceneSpecId)
signal letterTyped(letter)


export(float) var screenScrollSpeed = 300


onready var shooter = $MovingElements/ShooterShip
onready var textShipsContainer = $MovingElements/TextShips
onready var camera = $MovingElements/Camera2D
onready var shaker = $MovingElements/Camera2D/ScreenShake
onready var freeze = $FreezeFrame
onready var playerInput = $CanvasLayer/PlayerInput
onready var musicControl = $CanvasLayer/MusicControl
onready var shipsFactory = $TextShipFactory
onready var fsm: ShipSceneStateMachine = $ShipSceneStateMachine
onready var stateLabel: Label = $CanvasLayer/StateLabel


var currentShipTarget: TextShip


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
	

func _fsmStateChanged(oldState: String, newState: String):
	stateLabel.text = "state: [%s] -> [%s]" % [oldState, newState]
