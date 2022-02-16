extends Node2D


const COLOR_CHANGE_COEF = float(1.0 / 5.0)

signal bubbleBurst
signal bubbleHit(hitsRemaining)

export(Color) var bubbleMaxHitsColor = Color.green

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite
onready var rechargeTimer: Timer = $RechargeTimer
onready var hitsBar: ProgressBar = $HitsBar


var bubbleHit: bool = false
var hasBurst: bool = false

var bubbleMaxHits: int
# by default full shield is used
var bubbleHitsCurrent: int = 0
var currentBubbleDamageColor: Color

var ownerShip: Node2D


func _ready():
	bubbleHit = false
	Utils.tryConnect(rechargeTimer, "timeout", self, "_onBubbleRecharge")
	if (not bubbleMaxHits):
		_setMaxHitPoints(1)
	_updateBubbleColor()
	
	
	
func setInitialHitPoints(hitPoints: int):
	_setMaxHitPoints(hitPoints)
	

func show():
	anim.play("show")
	

func hide():
	anim.play("hide")
	
	
func _setMaxHitPoints(newMaxHitPoints: int):
	bubbleMaxHits = newMaxHitPoints
	bubbleHitsCurrent = 0
	currentBubbleDamageColor = bubbleMaxHitsColor
	_setupHitsBar(bubbleMaxHits)
	_updateBubbleColor()
	
	
func _setupHitsBar(maxHits: int):
	$HitsBar.max_value = maxHits
	_adjustHitsBarRemainingShieldHits(maxHits)
	$HitsBar.visible = false
	

func _adjustHitsBarRemainingShieldHits(hitsRemaining: int):
	$HitsBar.value = hitsRemaining
	$HitsBar.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	$HitsBar.visible = false
	if (hitsRemaining <= 0):
		$HitsBar.visible = false


func _onShipBodyAreaEnter(area):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		var collideProjectile = areaOwner
		var projectileText: String = collideProjectile.getText()
		#hit bubble for half the received word length (at least 1)
		var hitsReceived = max(1, projectileText.length() / 2)
		#destroy bubble if projectile payload is exact word match
		hitsReceived = bubbleMaxHits if projectileText == ownerShip.currentText else hitsReceived
		_hitBubble(hitsReceived)
			
			
func _hitBubble(hitsReceived: int):
	bubbleHitsCurrent += hitsReceived
	var hitsRemaining = max(0, bubbleMaxHits - bubbleHitsCurrent)
	emit_signal("bubbleHit", hitsRemaining)
	_adjustHitsBarRemainingShieldHits(hitsRemaining)
	if (hitsRemaining > 0):
		if (rechargeTimer.is_stopped()):
			rechargeTimer.start()
		_bubbleHitForAnimation("hit")
		_updateBubbleColor()
	else:
		_bubbleHitForAnimation("burst")
		hasBurst = true
		emit_signal("bubbleBurst")
	
	
func _bubbleHitForAnimation(animName: String): 
	sprite.self_modulate = Color.white
	bubbleHit = true
	anim.play(animName)
	yield(anim, "animation_finished")
	bubbleHit = false
			

func _updateBubbleColor():
	if (bubbleHitsCurrent < bubbleMaxHits):
		var bubbleHitsRemaining = bubbleMaxHits - bubbleHitsCurrent
		sprite.self_modulate = bubbleMaxHitsColor.lightened(1.0 - (COLOR_CHANGE_COEF * bubbleHitsRemaining))
	else:
		sprite.self_modulate = Color.transparent
		

func _onBubbleRecharge():
	bubbleHitsCurrent = max(0, bubbleHitsCurrent - 1)
	var hitsRemaining = bubbleMaxHits - bubbleHitsCurrent
	if (bubbleHitsCurrent == 0):
		rechargeTimer.stop()
	_updateBubbleColor()
	emit_signal("bubbleHit", hitsRemaining)
