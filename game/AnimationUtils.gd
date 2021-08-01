class_name Animations
"""
Static helpers for creating and editing animations
"""

"""
Creates new Animation instance and sets its length to provided argument
value. 
Returns created animation instance
"""
static func createAnimationOfLength(length: float = 1.0) -> Animation:
	var animation = Animation.new()
	animation.length = length
	return animation
	
	
"""
Add a new value track for the provided animation instance and returns the 
created associated track index
"""
static func addAnimationValueTrack(animation: Animation, valuePath: String) -> int:
	return _addAnimationTrackOfType(animation, valuePath, Animation.TYPE_VALUE)



"""
Add a new method track for the provided animation instance and returns the 
created associated track index
"""
static func addAnimationMethodTrack(animation: Animation, methodOwnerPath: String) -> int:
	return _addAnimationTrackOfType(animation, methodOwnerPath, Animation.TYPE_METHOD)



"""
Add value interpolation local to the animation timeline in a value track. 
Method validates that the interpolation is contained in the animation 
and the track index supplied is a value track
"""
static func addAnimationValueTrackInterpolation(animation: Animation, valueTrackIdx: int, fromValue, toValue, startTime: float = 0.0, interpolationTime: float = 1.0):
	assert(animation.length > startTime)
	assert(animation.length >= startTime + interpolationTime)
	_assertAnimationTrackAtIdxOfType(animation, valueTrackIdx, Animation.TYPE_VALUE)
	animation.track_insert_key(valueTrackIdx, startTime, fromValue)
	animation.track_insert_key(valueTrackIdx, startTime + interpolationTime, toValue)



"""
Add method invocation for a method track using supplied method name and args list at supplied time
"""
static func addAnimationMethodTrackInvocation(animation: Animation, methodTrackIdx: int, invocationTime: float, methodName: String, args: Array = []):
	assert(animation.length >= invocationTime)
	_assertAnimationTrackAtIdxOfType(animation, methodTrackIdx, Animation.TYPE_METHOD)
	animation.track_insert_key(methodTrackIdx, invocationTime, { "method": methodName, "args": args })






static func _addAnimationTrackOfType(animation: Animation, valuePath: String, trackType: int) -> int:
	assert(animation)
	assert(not Utils.isEmptyString(valuePath))
	var trackIdx = animation.add_track(trackType)
	animation.track_set_path(trackIdx, valuePath)
	return trackIdx


static func _assertAnimationTrackAtIdxOfType(animation: Animation, trackIdx: int, expectedType: int):
	var trackType: int = animation.track_get_type(trackIdx)
	assert(trackType == expectedType)
