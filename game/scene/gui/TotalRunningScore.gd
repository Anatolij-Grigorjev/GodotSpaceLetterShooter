tool
extends Control
"""
Running score total GUI control
Visualizes adding points to total score.
"""
const TOTAL_SCORE_FORMAT: String = "%06d"
const ADD_SCORE_FORMAT: String = "+%03d"

export(int) var totalScore: int = 0 setget _setTotalScore

onready var totalScoreLbl: Label = $VBoxContainer/ScoreLbl
onready var addedPointsLbl: Label = $VBoxContainer/AddedPointsLbl
onready var anim: AnimationPlayer = $AnimationPlayer
onready var addPointsDebounceTimer: Timer = $AddedPointsDebounce


var newAddedScore: int = 0
var runningStandalone: bool = false

func _ready():
	addedPointsLbl.visible = false
	Utils.tryConnect(addPointsDebounceTimer, "timeout", self, "_onAddPointsDebounceEnded")
	runningStandalone = get_tree().get_nodes_in_group("shooter").empty()
	
	
func _process(delta: float):
	if (runningStandalone):
		if Input.is_action_just_released("debug1"):
			addPoints(randi() % 300)
	
	
func addPoints(numPoints: int):
	if (Utils.animIsPlayingAnimation(anim, "hide_add")):
		_flushAddedScore()
	newAddedScore += numPoints
	addedPointsLbl.text = ADD_SCORE_FORMAT % newAddedScore
	anim.play("add_score")
	addPointsDebounceTimer.start()
	
	
func _setTotalScore(newTotal: int):
	totalScore = newTotal
	if ($VBoxContainer/ScoreLbl):
		$VBoxContainer/ScoreLbl.text = TOTAL_SCORE_FORMAT % totalScore
		
		
func _onAddPointsDebounceEnded():
	anim.play("hide_add")
	yield(anim, "animation_finished")
	_flushAddedScore()
	
	
func _flushAddedScore():
	_setTotalScore(totalScore + newAddedScore)
	newAddedScore = 0


