tool
extends Node2D
class_name TextShip
"""
Controller for ship with a piece of text in a label in a sprite
"""

export(String) var currentText: String = "test" setget setCurrentText, getCurrentText


onready var sprite: Sprite = $Sprite
onready var label: Label = $Sprite/Label
onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	$HitParticlesBattery.connect("activeParticlesWillEmit", self, "_repositionParticleSystem")
	$MissParticlesBattery.connect("activeParticlesWillEmit", self, "_repositionParticleSystem")
	

func hitCharacter() -> void:
	setCurrentText(currentText.substr(1))
	

func nextLetterIs(letter: String) -> bool:
	return currentText.begins_with(letter)
	
	
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
	return nextLetterIs(payload)
	

func _repositionParticleSystem(particles: Particles2D) -> void:
	var randomPosition: Vector2 = Vector2(
		rand_range(-1, 1),
		rand_range(-1, 1)
	) * 40
	particles.position = randomPosition
