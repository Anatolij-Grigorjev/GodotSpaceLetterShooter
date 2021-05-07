extends Node2D


signal bubbleBurst


export(Color) var bubbleMaxHitsColor = Color.green

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite


var bubbleHit: bool = false

var bubbleMaxHits: int
# by default full shield is used
var bubbleHitsCurrent: int = 0
var currentBubbleDamageColor: Color
var colorChangeCoef: float

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
	colorChangeCoef = 1.0 / float(bubbleMaxHits)
	_updateBubbleColor()


func _on_Area2D_area_entered(area: Area2D):
	var areaOwner: Node2D = area.get_parent()
	if (areaOwner.is_in_group("projectile")):
		var collideProjectile = areaOwner
		_hitBubble()
			
			
func _hitBubble():
	bubbleHitsCurrent += 1
	if (bubbleHitsCurrent < bubbleMaxHits):
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
		sprite.self_modulate = bubbleMaxHitsColor.lightened(colorChangeCoef * bubbleHitsCurrent)
	else:
		sprite.self_modulate = Color.transparent
		
		
