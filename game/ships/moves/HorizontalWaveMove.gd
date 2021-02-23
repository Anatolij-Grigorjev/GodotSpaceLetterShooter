extends Node
class_name HorizontalWaveMove


export(float) var velocity: float = 300
export(float) var minVerticalStep: float = 10
export(float) var maxVerticalStep: float = 30

onready var entity: Node2D = get_parent()
onready var tween: Tween = $Tween

var screenBounds: Vector2 = OS.window_size

func _ready():
	pass # Replace with function body.
	
	
