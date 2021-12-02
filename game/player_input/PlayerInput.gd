extends Control
"""
Panel to display latest player input 
while shoot-typing
"""

onready var label: Label = $Panel/Label
onready var audioPlayer: RandomAudioPlayer = $RandomTypingSound
onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	clearText()


func addTypedLetter(letter: String) -> void:
	label.text += letter
	audioPlayer.playRandom()
	
	

func clearText():
	label.text = ""
	

#ignored parameter is projectile from shotFired(projectile) signal
func flashInput(_ignored):
	anim.play("flash_input")
