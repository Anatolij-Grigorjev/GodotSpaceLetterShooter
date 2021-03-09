extends Node
class_name StateMachine
"""
Abstract state machine interface. A state machine lifecycle can be applied
to any kind of entity.
For lifecycles tailored for characters see
CharacterStateMachineTemplate.gd
"""
signal stateChanged(oldState, newState)


const NO_STATE: String = "<NO_STATE>"

export(String) var state: String = NO_STATE setget setState
#default entity path is direct parent
export(NodePath) var entityPath: NodePath = NodePath("..")

var previousState: String = NO_STATE
onready var entity: Node = get_node(entityPath)

var stateNodes = {}


func _ready() -> void:
	for node in get_children():
		var state = node as State
		if (state):
			stateNodes[state.name] = state
			state.fsm = self
			state.entity = entity
		

func _process(delta: float) -> void:
	if (state != NO_STATE):
		_processState(delta)
		var nextState = _getNextState(delta)
		if (nextState != NO_STATE):
			setState(nextState)
	

func setState(nextState: String):
	previousState = state
	state = nextState
	emit_signal("stateChanged", previousState, nextState)
	
	if (previousState != NO_STATE):
		_exitState(previousState, state)
		
	if (state != NO_STATE):
		_enterState(state, previousState)
	

func getState(state_name: String) -> State:
	return stateNodes[state_name]
		
		
func _enterState(nextState: String, prev_state: String):
	getState(prev_state).enterState(nextState)
	

func _exitState(prev_state: String, nextState: String):
	getState(prev_state).exitState(nextState)


func _processState(delta: float):
	getState(state).processState(delta)


func _getNextState(delta: float) -> String:
	return NO_STATE
