extends Node2D
"""
An action that can be attached to a given Camera2D to perform 
screen shake on-demand
"""
const TRANSITION = Tween.TRANS_SINE
const EASING = Tween.EASE_OUT_IN

signal onShakeEnded

var amplitude = 0
var priority = 0

onready var camera: Camera2D = get_parent()


func beginShake(duration = 0.2, frequency = 15, amplitude = 10, priority = 1):
	_onCameraShakeRequested(duration, frequency, amplitude, priority)


func _newShake():
	var rand_offset = Utils.rand_point(amplitude, amplitude)
	
	$ShakeTween.interpolate_property(
		camera, 'offset', 
		camera.offset, rand_offset, 
		$Frequency.wait_time, TRANSITION, EASING
	)
	$ShakeTween.start()


func _reset():
	priority = 0
	camera.offset = Vector2.ZERO


func _onFrequencyTimeout():
	_newShake()


func _onDurationTimeout():
	_reset()
	$Frequency.stop()
	emit_signal("onShakeEnded")
	


func _onCameraShakeRequested(duration = 0.2, frequency = 15, amplitude = 10, priority = 1):
	if (priority < self.priority):
		return
	
	self.amplitude = amplitude
	self.priority = priority
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	$Duration.start()
	$Frequency.start()
	
	_newShake()
