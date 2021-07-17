extends Label
"""
Label to display latest state transitions of a source FSM
"""

export(NodePath) var sourceFSM: NodePath = ".."

onready var fsm: StateMachine = get_node(sourceFSM)

func _ready():
	Utils.tryConnect(fsm, "stateChanged", self, "_onFSMStateChanged")
	
	
func _onFSMStateChanged(prevState: String, nextState: String):
	text = "%s -> %s" % [prevState, nextState]
