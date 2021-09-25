extends Node
class_name TextShipStateMachineExtension
"""
Abstract interface for extensions of state processing needed
for fancier text ships
"""
const NO_STATE: String = "<NO_STATE>"
const NO_STATE_MATCHED = "<???>"

export(NodePath) var ownerFSMPath: NodePath = NodePath("..")

onready var ownerFSM = get_node(ownerFSMPath)


func initExtension():
	pass
	
	
func tryProcessCurrentState(state: String, delta: float) -> String:
	return NO_STATE_MATCHED
