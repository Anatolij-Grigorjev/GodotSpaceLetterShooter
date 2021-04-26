class_name SceneShipLimits
"""
Limiters for allowed ship stats/behavior during a wave
"""

var shipSpeed: float = 450.0
var shieldHitPoints: int = 3
var shootInclination: int = 0

func _init(speed: float, shieldHP: int, shootWeight: int):
	shipSpeed = speed
	shieldHitPoints = shieldHP
	shootInclination = shootWeight


func _to_string():
	return "S:%s|A:%s|F:%s" % [round(shipSpeed), shieldHitPoints, shootInclination]
