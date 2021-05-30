extends Node2D
"""
Scene where text ships descend while player types 
and bottom ship shoots the descenders based on text
"""
signal sceneCleared(sceneSpecId)
signal sceneFailed(sceneSpecId)
signal letterTyped(letter)


onready var shooter = $ShooterShip
onready var playerInput = $CanvasLayer/PlayerInput
onready var musicControl = $CanvasLayer/MusicControl
onready var shipsFactory = $TextShipFactory
onready var fsm: ShipSceneStateMachine = $ShipSceneStateMachine
onready var stateLabel: Label = $CanvasLayer/StateLabel


func _ready():
	randomize()
	call_deferred("_bindSceneStats")
	
	
func _process(delta: float):
	stateLabel.text = "state: %s" % fsm.state
	
	

func setSceneSpecificaion(spec: SceneSpec):
	get_node("ShipSceneStateMachine").sceneSpecification = spec
	

func _bindSceneStats():
	Stats.currentScene = self
