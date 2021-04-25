extends Node2D


signal bubbleBurst


export(Array, Color) var bubbleDamageColors = [
	Color.red,
	Color.green,
	Color.blue
]

onready var anim: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite


var bubbleHit: bool = false

var bubbleMaxHits: int
var bubbleHitsCurrent: int = -1

func _ready():
	bubbleHit = false
	bubbleMaxHits = bubbleDamageColors.size()
	#no external setting, use default
	if (bubbleHitsCurrent == -1):
		bubbleHitsCurrent = bubbleMaxHits
	_updateBubbleColor()
	
	
func setInitialHitPoints(hitPoints: int):
	bubbleHitsCurrent = clamp(bubbleMaxHits - hitPoints, 0, bubbleMaxHits)


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
	if (bubbleHitsCurrent < bubbleDamageColors.size()):
		sprite.self_modulate = bubbleDamageColors[bubbleHitsCurrent]
	else:
		sprite.self_modulate = Color.transparent
		
		
