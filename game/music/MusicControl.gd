tool
extends Control
"""
Controller for music playing during stage. 
Uses input to enable/disable music
"""

export(AudioStream) var music setget _setMusic
export(bool) var playbackEnabled: bool = true setget _setPlaybackEnabled
export(bool) var currentlyPlaying: bool = false setget _setPlaying

onready var player: AudioStreamPlayer = $MusicPlayer


func _process(delta: float):
	if (Input.is_action_just_released("toggle_music")):
		_setPlaybackEnabled(not playbackEnabled)


func _setPlaying(shouldBePlaying: bool):
	if (currentlyPlaying == shouldBePlaying):
		return
		
	currentlyPlaying = shouldBePlaying
	if (currentlyPlaying and playbackEnabled):
		player.playing = true
	else:
		player.playing = false
	
	
func _setPlaybackEnabled(enable: bool):
	playbackEnabled = enable
	if ($MusicPlayer):
		if ($MusicPlayer.playing and not playbackEnabled):
			$MusicPlayer.playing = false
		if (not $MusicPlayer.playing and playbackEnabled and currentlyPlaying):
			$MusicPlayer.playing = true
	if ($MusicIcon/DisabledIcon):
		$MusicIcon/DisabledIcon.visible = not playbackEnabled
	
	
func _setMusic(newMusic: AudioStream):
	music = newMusic
	if ($MusicPlayer):
		$MusicPlayer.stream = music
