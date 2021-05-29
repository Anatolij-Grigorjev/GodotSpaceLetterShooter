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



func _ready():
	randomize()
	Stats.currentScene = self
	

func setSceneSpecificaion(spec: SceneSpec):
	get_node("ShipSceneStateMachine").sceneSpecification = spec
	
