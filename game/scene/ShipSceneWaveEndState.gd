extends State
class_name ShipSceneWaveEndState
"""
State for logic associated with end of a wave - showning statistics
and rolling over to next wave OR scene end
"""
const StatsViewScn = preload("res://scene_stats/SceneStatsView.tscn")


var statsViewClosed: bool = false
var statsViewAdded: bool = false
var shipDestroyed: bool = false
var shipLeaving: bool = false
var shipLeft: bool = false
var statsCookerThread: Thread


func _ready():
	statsCookerThread = Thread.new()


func enterState(prevState: String):
	.enterState(prevState)
	shipLeaving = false
	shipLeft = false
	shipDestroyed = false
	statsViewAdded = false
	statsViewClosed = false
	statsCookerThread.start(self, "_buildSceneStats", null)
	if (fsm.shooterFailed):
		yield(_playShipAnimationAndWait("destroy", 0.75), "completed")
		shipDestroyed = true
	
	
func processState(delta: float):
	.processState(delta)
	#step 1 - destroy failed ship
	if (fsm.shooterFailed and not shipDestroyed):
		return
	#step 2 - cook stats view
	if (not statsViewAdded):
		var statsViewNode = statsCookerThread.wait_to_finish()
		entity.get_node("CanvasLayer").add_child(statsViewNode)
		statsViewAdded = true
	#step 3 - wait for stats to close
	if (not statsViewClosed):
		return
	#finish state after stats if ship was destroyed
	if (shipDestroyed):
		shipLeft = true
	#step 4 - play leave animation
	if (not shipLeaving and not shipDestroyed):
		shipLeaving = true
		entity.shooter.fsm.state = "LeavingWave"
		yield(get_tree(), "idle_frame")
		yield(entity.shooter.fsm, "stateChanged")
		shipLeft = true
		
		
	
func _buildSceneStats(data):
	var statsView = StatsViewScn.instance()
	statsView.sceneName = fsm.sceneSpecification.sceneName
	statsView.setData(Stats.currentSceneStats)
	Utils.tryConnect(statsView, "statsViewKeyPressed", self, "_onStatsViewKeyPressed")
	return statsView


func _onStatsViewKeyPressed(statsView: Control):
	statsView.queue_free()
	statsViewClosed = true
	
	
func _playShipAnimationAndWait(animName: String, postAnimWaitTime: float):
	entity.shooter.anim.play(animName)
	yield(entity.shooter.anim, "animation_finished")
	if (postAnimWaitTime > 0):
		yield(get_tree().create_timer(postAnimWaitTime), "timeout")
