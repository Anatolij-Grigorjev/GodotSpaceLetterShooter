extends Control
"""
Panel to display latest player input 
while shoot-typing
"""

onready var label: Label = $Panel/Label
onready var audioPlayer: AudioStreamPlayer = $AudioStreamPlayer


var typingSounds: Array = []


func _ready():
	typingSounds = _loadTypingSounds()
	clearText()


func addTypedLetter(letter: String) -> void:
	label.text += letter
	audioPlayer.stream = typingSounds[randi() % typingSounds.size()]
	audioPlayer.play()
	

func clearText():
	label.text = ""
	
	
func _loadTypingSounds() -> Array:
	var loadedSounds := []
	var fileNameSuffix := 1
	var lastLoadedSound: AudioStream = _loadSoundSuffixed(fileNameSuffix)
	while(lastLoadedSound != null):
		fileNameSuffix += 1
		loadedSounds.append(lastLoadedSound)
		lastLoadedSound = _loadSoundSuffixed(fileNameSuffix)
	
	return loadedSounds
	
	
func _loadSoundSuffixed(suffix: int):
	return load("res://player_input/type_key" + str(suffix) + ".wav")
