extends Node
class_name HorizontalWaveMove


export(float) var velocity: float = 300
export(float) var minVerticalStep: float = 10
export(float) var maxVerticalStep: float = 30
export(bool) var enabled: bool = false setget setEnabled

onready var entity: Node2D = get_parent()
onready var tween: Tween = $Tween

var screenBounds: Vector2 = OS.window_size

func _ready():
	pass # Replace with function body.
	

func setEnabled(enable: bool) -> void:
	enabled = enable
	if (enabled):
		call_deferred("_recurTweenIterations")


func _recurTweenIterations() -> void:
	_addMoveTween()
	tween.start()
	yield(tween, "tween_all_completed")
	tween.stop_all()
	_recurTweenIterations()
	

func _addMoveTween() -> void:
	var stepDownHeight: float = minVerticalStep + randf() * (maxVerticalStep - minVerticalStep)
	var destinationX: float = screenBounds.x if entity.position.x < screenBounds.x / 2 else 0
	var destination: Vector2 = Vector2(destinationX, entity.position.y + stepDownHeight)
	
	var moveTime: float = destination.distance_to(entity.position) / velocity
	
	tween.interpolate_property(
		entity,
		"position",
		null,
		destination,
		moveTime,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
