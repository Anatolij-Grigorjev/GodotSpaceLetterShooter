tool
extends Node2D
"""
Controller for floating text that gets thrown out of fast ship and can be
picked up by any descending ship to increase its text
"""

export(String) var text: String = "T" setget setText



func _ready():

	$Tween.interpolate_property(
		self, "position", 
		null, position + Vector2(0, rand_range(80, 120)),
		0.5, Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	$Tween.start()



func setText(newText: String):
	text = newText
	if ($Sprite/Label):
		$Sprite/Label.text = text


func _on_Area2D_area_entered(area):
	var areaOwner = area.owner
	if areaOwner.is_in_group("text_ship"):
		areaOwner.collectFloatingText(text)
		queue_free()
