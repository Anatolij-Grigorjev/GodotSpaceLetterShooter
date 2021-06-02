extends State
class_name ShipSceneWaveEndState
"""
State for logic associated with end of a wave - showning statistics
and rolling over to next wave OR scene end
"""
const StatsViewScn = preload("res://scene_stats/SceneStatsView.tscn")


var statsViewClosed: bool = false
var statsViewAdded: bool = false
var shipLeft: bool = false
var statsCookerThread: Thread


func _ready():
	statsCookerThread = Thread.new()


func enterState(prevState: String):
	.enterState(prevState)
	shipLeft = false
	statsViewAdded = false
	statsViewClosed = false
	statsCookerThread.start(self, "_buildSceneStats", null)
	entity.currentShipTarget = null
	if (fsm.shooterFailed):
		entity.shooter.anim.play("destroy")
	else:
		entity.shooter.anim.play("leave")
	yield(entity.shooter.anim, "animation_finished")
	yield(get_tree().create_timer(0.75), "timeout")
	shipLeft = true
	
	
func processState(delta: float):
	.processState(delta)
	if (not shipLeft or statsViewClosed):
		return
	if (not statsViewAdded):
		var statsViewNode = statsCookerThread.wait_to_finish()
		entity.get_node("CanvasLayer").add_child(statsViewNode)
		statsViewAdded = true
	
	
	
func _buildSceneStats(data):
	var statsView = StatsViewScn.instance()
	statsView.sceneName = fsm.sceneSpecification.sceneName
	statsView.setData(Stats.currentSceneStats)
	Utils.tryConnect(statsView, "statsViewKeyPressed", self, "_onStatsViewKeyPressed")
	return statsView


func _onStatsViewKeyPressed(statsView: Control):
	statsView.queue_free()
	statsViewClosed = true
	
	
