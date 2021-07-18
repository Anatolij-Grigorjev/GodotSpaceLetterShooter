extends Label
"""
Label to display latest state transitions of a source FSM
"""

export(NodePath) var sourceFSM: NodePath = ".."
export(float) var showPrevStateTimeout: float = 1.0

onready var fsm: StateMachine = get_node(sourceFSM)
onready var timer: Timer = $PrevStateTimeout


var prevState: String = StateMachine.NO_STATE
var currentState: String = StateMachine.NO_STATE


func _ready():
	Utils.tryConnect(fsm, "stateChanged", self, "_onFSMStateChanged")
	timer.wait_time = showPrevStateTimeout
	timer.connect("timeout", self, "_onPrevStateDispalyTimeout")
	
	
func _onFSMStateChanged(prevState: String, nextState: String):
	self.prevState = prevState
	self.currentState = nextState
	timer.start()
	text = "%s -> %s" % [self.prevState, self.currentState]
	
	
func _onPrevStateDispalyTimeout():
	text = self.currentState 
