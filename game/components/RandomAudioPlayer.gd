extends AudioStreamPlayer
class_name RandomAudioPlayer
"""
An audio player variant that has a static list
of audio resources to play and will play a random one
when asked
"""
export(Array, AudioStream) var soundsList = []
	

func playRandom():
	var nextSound = soundsList[randi() % soundsList.size()]
	stream = nextSound
	play()
