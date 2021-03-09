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
var entity: Node setget setEntity
var isActive: bool = false


func _ready():
	isActive = false
	set_process(false)
	set_physics_process(false)


func processState(delta: float):
	pass
	
	
func enterState(prev_state: String):
	isActive = true
	
	
func exitState(next_state: String):
	isActive = false
		
		
func setFsm(set_fsm):
	fsm = set_fsm


func setEntity(set_entity: Node):
	entity = set_entity
