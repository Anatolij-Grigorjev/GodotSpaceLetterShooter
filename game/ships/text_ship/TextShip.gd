tool
extends Node2D
class_name TextShip
"""
Controller for ship with a piece of text in a label in a sprite
"""
signal textShipCollidedShooter
signal textShipDestroyed(text)

export(String) var currentText: String = "test" setget setCurrentText, getCurrentText
export(float) var speed: float = 450

onready var fsm: StateMachine = $TextShipStateMachine
onready var sprite: Sprite = $Sprite
onready var projectilePosition: Position2D = $Sprite/Nose/ProjectilePosition
onready var label: Label = $Sprite/Label
onready var bubble = $Sprite/ShipBubble
onready var anim: AnimationPlayer = $AnimationPlayer
onready var thrusterLeft: Particles2D = $Thrusters/ThrusterLeft
onready var thrusterRight: Particles2D = $Thrusters/ThrusterRight
onready var thrustersAudio: AudioStreamPlayer = $Thrusters/AudioStreamPlayer2D

func _ready():
	bubble.anim.play("hide")
	

func hitCharacter(numChars: int) -> void:
	setCurrentText(currentText.substr(numChars))
	

func nextTextIs(text: String) -> bool:
	return currentText.begins_with(text)
	
	
func prepare(text: String, startPosition: Vector2, shipPath: Array):
	setCurrentText(text)
	position = startPosition
	$Sprite.scale = Vector2.ZERO
	$TextShipStateMachine/Descending.descendPath = shipPath
	
	
func _process(delta: float):
	pass


func setCurrentText(text: String) -> void:
	currentText = text.to_upper()
	if ($Sprite/Label):
		var label = $Sprite/Label
		label.text = currentText
		
		
func getCurrentText() -> String:
	if ($Sprite/Label):
		return $Sprite/Label.text
	else:
		return currentText
	
	
func projectileHitText(projectile: Node2D) -> bool:
	var payload: String = projectile.label.text
	return not payload.empty() and nextTextIs(payload)
	
	
func disableThrusters():
	thrustersAudio.playing = false
	thrusterLeft.emitting = false
	thrusterRight.emitting = false
