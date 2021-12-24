extends State
class_name HitByShotState
"""
State describing situations of textship getting hit by a shot
If the shot payload matches the ship text this hit will reduce 
textship health. 
"""

var hitRecoveryTime: float = 1.5

var hitPosition: Vector2
var shotVelocity: Vector2
var shotPayload: String


var spriteTween: Tween

var shotPayloadWasMatch: bool = false


func _ready():
	spriteTween = Tween.new()
	add_child(spriteTween)
	_clearShotValues()
	


func setCollisionShotProperties(collisionShot: Node2D):
	var colliderBodyState = _getShotRigidBodyDirectState(collisionShot)
	hitPosition = entity.to_local(colliderBodyState.get_contact_collider_position(0))
	shotVelocity = colliderBodyState.linear_velocity
	shotPayload = collisionShot.getText()


func processState(delta: float):
	.processState(delta)
	
	
func enterState(prevState: String):
	.enterState(prevState)
	_assertColliderValuesSet()
	if entity.currentText.begins_with(shotPayload):
		shotPayloadWasMatch = true
		Animations.animPlayAnimationInTime(entity.anim, "hit", hitRecoveryTime)
		_reduceShipTextByShotPayload()
	var hitSpinDirection = _getHitSpinDirection()
	_startHitSpinTween(hitSpinDirection)
	
	
	
func exitState(nextState: String):
	.exitState(nextState)
	_clearShotValues()
	spriteTween.stop_all()
	spriteTween.remove_all()
	



func _getShotRigidBodyDirectState(shot: Node2D) -> Physics2DDirectBodyState:
	var body = shot.ownBody as RigidBody2D
	return Physics2DServer.body_get_direct_state(body.get_rid())
	
	
func _clearShotValues():
	hitPosition = Vector2.ZERO
	shotVelocity = Vector2.ZERO
	shotPayload = ""
	shotPayloadWasMatch = false
	
	
func _getHitSpinDirection() -> int:
	if (hitPosition.x <= entity.bodySize.x / 2):
		#CW spin direction
		return 1
	else:
		#CCW spin direction
		return -1


func _startHitSpinTween(spinDirection: int):
	spriteTween.interpolate_property(
		entity.sprite, "rotation_degrees", 
		0, 360, 
		hitRecoveryTime, 
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	spriteTween.start()


func _reduceShipTextByShotPayload():
	entity.currentText = entity.currentText.substr(shotPayload.length())



func _assertColliderValuesSet():
	assert(not Utils.isEmptyString(shotPayload))
	assert(not hitPosition == Vector2.ZERO)
	assert(not shotVelocity == Vector2.ZERO)
	
