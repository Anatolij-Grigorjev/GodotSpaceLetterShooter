extends State
class_name HitByShotState
"""
State describing situations of textship getting hit by a shot
If the shot payload matches the ship text this hit will reduce 
textship health. 
"""

const UNSET_VECTOR = Vector2(-99999, -99999)

var hitRecoveryTime: float = 0.45

var hitPosition: Vector2 = UNSET_VECTOR
var shotVelocity: Vector2 = UNSET_VECTOR
var shotPayload: String

var shotPayloadWasMatch: bool = false

var preHitText: String = ""


func _ready():
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
	
	entity.emit_signal("shipHit", entity.currentText.length())
	#store how much text there was before hit for stats
	preHitText = str(entity.currentText)
	
	if entity.currentText.begins_with(shotPayload):
		shotPayloadWasMatch = true
		Animations.animPlayAnimationInTime(entity.anim, "hit", hitRecoveryTime)
		_reduceShipTextByShotPayload()
	
	
	
func exitState(nextState: String):
	.exitState(nextState)
	_clearShotValues()
	



func _getShotRigidBodyDirectState(shot: Node2D) -> Physics2DDirectBodyState:
	var body = shot.ownBody as RigidBody2D
	return Physics2DServer.body_get_direct_state(body.get_rid())
	
	
func _clearShotValues():
	hitPosition = UNSET_VECTOR
	shotVelocity = UNSET_VECTOR
	shotPayload = ""
	shotPayloadWasMatch = false


func _reduceShipTextByShotPayload():
	entity.currentText = entity.currentText.substr(shotPayload.length())



func _assertColliderValuesSet():
	assert(not Utils.isEmptyString(shotPayload))
	assert(hitPosition != UNSET_VECTOR)
	assert(shotVelocity != UNSET_VECTOR)
	
