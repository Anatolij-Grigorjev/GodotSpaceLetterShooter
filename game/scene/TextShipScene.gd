extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal sceneCleared(sceneSpecId)
signal sceneFailed(sceneSpecId)
signal letterTyped(letter)


export(float) var screenScrollSpeed = 300


onready var shooter = $ShooterShip
onready var camera = $Camera2D
onready var shaker = $Camera2D/ScreenShake
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
	camera.position.y -= screenTravel
	shooter.position.y -= screenTravel
	$TextShips.position.y -= screenTravel
		
	

func setSceneSpecificaion(spec: SceneSpec):
	get_node("ShipSceneStateMachine").sceneSpecification = spec
	

func _bindSceneStats():
	Stats.currentScene = self
	
	
func _onShooterClearChamber():
	for ship in $TextShips.get_children():
		ship.isTargeted = false
		
		
func _startTextShipHitShake(textShip: TextShip):
	shaker.beginShake()
	

func _fsmStateChanged(oldState: String, newState: String):
	stateLabel.text = "state: [%s] -> [%s]" % [oldState, newState]
