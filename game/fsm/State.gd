extends Node
class_name State
"""
Abstract state machine state interface. 
Nodes implementing this can be children of a state machine
This node allows referencing the parent state machine and root entity
turns off physics by default to get processed ONLY via FSM
"""
# type should be derived from StateMachine, 
# not explicit due to cyclic type loading
var fsm setget setFsm
var entity: Node2D setget setEntity
var isActive: bool = false
var stateTime: float = 0.0


func _ready():
	isActive = false
	set_process(false)
	set_physics_process(false)


func processState(delta: float):
	stateTime += delta
	
	
func enterState(prevState: String):
	isActive = true
	stateTime = 0.0
	
	
func exitState(nextState: String):
	isActive = false
	
		
func setFsm(newFsm):
	fsm = newFsm


func setEntity(newEntity: Node2D):
	entity = newEntity
