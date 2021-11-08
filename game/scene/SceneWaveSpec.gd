class_name SceneWaveSpec
"""
Data used by TextShipFactory to construct a single wave
of ships during a scene
"""

var numShips: int
var firstShipStartPos: Vector2
"""
Array of String ids defining what kind of ship is required (with duplicates)
"""
var shipTypes: Array


func _init(totalWaveShips: int, shipsStartPos: Vector2, sceneShipTypeIdsToReserve: Dictionary):
	numShips = totalWaveShips
	firstShipStartPos = shipsStartPos
	#flatten num of allowed each ship type to provide factory with array
	shipTypes = []
	for shipTypeId in sceneShipTypeIdsToReserve:
		var shipTypeReserves: int = sceneShipTypeIdsToReserve[shipTypeId]
		Utils.appendNTimes(shipTypes, shipTypeId, shipTypeReserves)
	shipTypes.shuffle()
	if (totalWaveShips < shipTypes.size()):
		shipTypes.resize(totalWaveShips)
