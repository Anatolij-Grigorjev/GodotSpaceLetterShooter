extends State
class_name StateMachineState
"""
A kind of state that manages an internal FSM lifecycle
"""
signal stateChanged(oldState, newState)

export(String) var initialState: String = StateMachine.NO_STATE

export(String) var state: String = StateMachine.NO_STATE setget setState

var previousState: String = StateMachine.NO_STATE

var stateNodes = {}

var fsmStopped: bool = false


func _ready():
	for node in get_children():
		var state = node as State
		if (state):
			stateNodes[state.name] = state
			state.fsm = self
			

func setState(nextState: String):
	previousState = state
	state = nextState
	emit_signal("stateChanged", previousState, nextState)
	
	if (previousState != StateMachine.NO_STATE):
		_exitState(previousState, state)
		
	if (state != StateMachine.NO_STATE):
		_enterState(state, previousState)
	

func getState(state_name: String) -> State:
	return stateNodes[state_name]
		
		
func _enterState(nextState: String, prevState: String):
	getState(nextState).enterState(prevState)
	

func _exitState(prevState: String, nextState: String):
	getState(prevState).exitState(nextState)
	

func _getNextState(delta: float) -> String:
	return StateMachine.NO_STATE
	

func processState(delta: float):
	if (state != StateMachine.NO_STATE):
		getState(state).processState(delta)
		var nextState = _getNextState(delta)
		if (nextState != StateMachine.NO_STATE):
			setState(nextState)
	
	
func enterState(prevState: String):
	.enterState(prevState)
	fsmStopped = false
	setState(initialState)

	
func exitState(nextState: String):
	.exitState(nextState)


func setEntity(newEntity: Node2D):
	.setEntity(newEntity)
	for node in stateNodes.values():
		node.entity = newEntity
