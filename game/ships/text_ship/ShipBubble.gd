extends Node2D


const COLOR_CHANGE_COEF = float(1.0 / 5.0)

signal bubbleBurst
signal bubbleHit(hitsRemaining)

export(Color) var bubbleMaxHitsColor = Color.green

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite


var bubbleHit: bool = false

var bubbleMaxHits: int
# by default full shield is used
var bubbleHitsCurrent: int = 0
var currentBubbleDamageColor: Color


func _ready():
	bubbleHit = false
	if (not bubbleMaxHits):
		_setMaxHitPoints(1)
	_updateBubbleColor()
	
	
	
func setInitialHitPoints(hitPoints: int):
	_setMaxHitPoints(hitPoints)
	
	
func _setMaxHitPoints(newMaxHitPoints: int):
	bubbleMaxHits = newMaxHitPoints
	bubbleHitsCurrent = 0
	currentBubbleDamageColor = bubbleMaxHitsColor
	_updateBubbleColor()


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		var collideProjectile = areaOwner
		#hit bubble for half the received word length
		_hitBubble(collideProjectile.getText().length() / 2)
			
			
func _hitBubble(hitsReceived: int):
	bubbleHitsCurrent += hitsReceived
	var hitsRemaining = max(0, bubbleMaxHits - bubbleHitsCurrent)
	emit_signal("bubbleHit", hitsRemaining)
	if (hitsRemaining > 0):
		_bubbleHitForAnimation("hit")
		_updateBubbleColor()
	else:
		_bubbleHitForAnimation("burst")
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
		
		
