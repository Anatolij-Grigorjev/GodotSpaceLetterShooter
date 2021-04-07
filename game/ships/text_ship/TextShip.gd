tool
extends Node2D
class_name TextShip
"""
Controller for ship with a piece of text in a label in a sprite
"""
signal textShipCollidedShooter
signal textShipDestroyed

export(String) var currentText: String = "test" setget setCurrentText, getCurrentText
export(float) var speed: float = 450
export(Dictionary) var initialIdlingActionsWeights = {
	"Idling": 1.0,
	"IdlingBubble": 1.0,
	"IdlingShoot": 1.0
}


onready var sprite: Sprite = $Sprite
onready var projectilePosition: Position2D = $Sprite/Nose/ProjectilePosition
onready var label: Label = $Sprite/Label
onready var bubble = $Sprite/ShipBubble
onready var anim: AnimationPlayer = $AnimationPlayer
onready var thrusterLeft: Particles2D = $Thrusters/ThrusterLeft
onready var thrusterRight: Particles2D = $Thrusters/ThrusterRight
onready var thrustersAudio: AudioStreamPlayer = $Thrusters/AudioStreamPlayer2D


var startPosition: Vector2
var idlingActionsWeights: Dictionary

func _ready():
	idlingActionsWeights = initialIdlingActionsWeights.duplicate(true)
	bubble.anim.play("hide")
	pass
	

func hitCharacter(numChars: int) -> void:
	setCurrentText(currentText.substr(numChars))
	

func nextTextIs(text: String) -> bool:
	return currentText.begins_with(text)
	
	
func prepare(text: String, startPosition: Vector2):
	setCurrentText(text)
	position = startPosition
	startPosition = startPosition
	
	
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
	

func _repositionParticleSystem(particles: Particles2D) -> void:
	var randomPosition: Vector2 = Vector2(
		rand_range(-1, 1),
		rand_range(-1, 1)
	) * 40
	particles.position = randomPosition
	
	
func disableThrusters():
	thrustersAudio.playing = false
	thrusterLeft.emitting = false
	thrusterRight.emitting = false
