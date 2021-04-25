class_name SceneWaveSpec
"""
Data used by TextShipFactory to construct a single wave
of ships during a scene
"""

var numShips: int
var firstShipStartPos: Vector2
"""
Array of SceneShipLimits, exploded from allowed bins in
main SceneSpec
"""
var shipTypes: Array


func _init(totalWaveShips: int, shipsStartPos: Vector2, allowedCountedWaveShipTypes: Dictionary):
	numShips = totalWaveShips
	firstShipStartPos = shipsStartPos
	#flatten num of allowed each ship type to provide factory with array
	shipTypes = []
	for shipLimits in allowedCountedWaveShipTypes:
		for idx in range(allowedCountedWaveShipTypes[shipLimits]):
			shipTypes.append(shipLimits)
	shipTypes.shuffle()
	shipTypes.resize(totalWaveShips)
