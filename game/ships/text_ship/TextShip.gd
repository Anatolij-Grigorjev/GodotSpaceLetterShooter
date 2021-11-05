tool
extends Node2D
class_name TextShip
"""
Controller for ship with a piece of text in a label in a sprite
"""
signal shotFired(projectileNode)
signal textShipCollidedShooter
signal textShipReachedFinish
signal textShipDestroyed(text)
signal shipHit(lettersRemaining)
signal shipHitEarnedPoints(points, shipPosition)
signal shipDroppedLetter(floatingLetterNode)
signal shipPickedUpText(currentText)


export(String) var currentText: String = "test" setget setCurrentText, getCurrentText
export(bool) var isTargeted: bool = false setget _setAsTarget
export(float) var speed: float = 450
export(int) var baseKillPoints: int = 300 
export(int) var perLetterBonusPoints: int = 41


onready var fsm: StateMachine = $TextShipStateMachine
onready var sprite: Sprite = $Sprite
onready var label: Label = $Sprite/Label
onready var bubble = $Sprite/ShipBubble
onready var anim: AnimationPlayer = $AnimationPlayer
onready var thrusterLeft: Particles2D = $Thrusters/ThrusterLeft
onready var thrusterRight: Particles2D = $Thrusters/ThrusterRight
onready var thrustersAudio: AudioStreamPlayer = $Thrusters/AudioStreamPlayer2D
onready var bodyArea: Area2D = $Area2D


var shipHasShield: bool = false


var actionWeights := {}

func _ready():
	#every ship instance has unique material instance
	sprite.material = sprite.material.duplicate(true)
	
	if is_instance_valid(bubble):
		bubble.ownerShip = self
		bubble.anim.play("hide")
	#set FSM idling weights
	for action in actionWeights:
		fsm.idlingActionsWeights.setItemWeight(action, actionWeights[action])
	
	

func hitCharacter(numChars: int) -> void:
	setCurrentText(currentText.substr(numChars))
	

func nextTextIs(text: String) -> bool:
	return currentText.begins_with(text)
	
	
func prepare(text: String, startPosition: Vector2, shipPath: Array, limiters: SceneShipLimits):
	setCurrentText(text)
	position = startPosition
	$Sprite.scale = Vector2.ZERO
	$TextShipStateMachine/Descending.descendPath = shipPath
	speed = limiters.shipSpeed
	if ($Sprite/ShipBubble):
		$Sprite/ShipBubble.setInitialHitPoints(limiters.shieldHitPoints)
	shipHasShield = limiters.shieldHitPoints > 0
	var shipWillShoot := limiters.shootInclination > 0
	actionWeights = {
		"Idling": 1,
		"IdlingBubble": (1 if shipHasShield else 0),
		"IdlingShoot": limiters.shootInclination
	}
	


func setCurrentText(text: String) -> void:
	currentText = text.to_upper()
	if ($Sprite/Label):
		var label = $Sprite/Label
		label.text = currentText
		
		
func getCurrentText() -> String:
	if ($Sprite/Label):
		return $Sprite/Label.text
	else:
		return currentText
		
		
func collectFloatingText(text: String):
	setCurrentText(currentText + text)
	anim.play("pickup_text")
	emit_signal("shipPickedUpText", currentText)
		
		
func _setAsTarget(isTarget: bool):
	isTargeted = isTarget
	if (
		$Sprite/Target 
		and isTargeted
		and not $Sprite/Target.targetVisible()
	):
		$Sprite/Target.lockin()
		if (not shipHasShield):
			_animateTargetIfInputTextExactMatch()
	elif (
		$Sprite/Target 
		and not isTargeted
		and $Sprite/Target.targetVisible()
	):
		$Sprite/Target.lockout()
			
			
func _pulseTarget(letter: String):
	$Sprite/Target.pulse()
	if (not shipHasShield):
		_animateTargetIfInputTextExactMatch()
		
		
		
func lockTarget():
	$Sprite/Target.lockout()
	isTargeted = false
	
	
func bodyCollider() -> CollisionShape2D:
	return bodyArea.get_node("CollisionShape2D") as CollisionShape2D
	
	
func projectileHitText(projectile: Node2D) -> bool:
	if not projectile.has_method("getText"):
		print("NOT PROJECTILE: %s" % projectile)
		return false
	var payload: String = projectile.getText()
	return not payload.empty() and nextTextIs(payload)
	
	
func disableThrusters():
	thrustersAudio.playing = false
	thrusterLeft.emitting = false
	thrusterRight.emitting = false
		

func _animateTargetIfInputTextExactMatch():
	var inputText: String = Utils.getFirstTreeNodeInGroup(get_tree(), "input").label.text
	if (inputText == getCurrentText()):
		$Sprite/Target.anim.play("exact_match")
