extends State
class_name IdlingState
"""
State for text ship to idle for fixed amount of time.
Typically between descend segments
"""
export(float) var idleTime: float = 0.5


var remainingIdleTime: float = 0.0
var idlingOver: bool = false


func processState(delta: float):
	if (idlingOver):
		return
		
	remainingIdleTime -= delta
	if (remainingIdleTime < 0.0):
		idlingOver = true
		return
	
	
func enterState(prevState: String):
	.enterState(prevState)
	remainingIdleTime = idleTime
	idlingOver = false
	
	
func exitState(nextState: String):
	.exitState(nextState)
