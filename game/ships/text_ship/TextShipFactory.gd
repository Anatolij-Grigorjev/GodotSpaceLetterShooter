extends Node
"""
Facility creates and configures text ship instances in a 
background thread to make them ready for next wave participation
"""
const TextShipScn = preload("res://ships/text_ship/TextShip.tscn")

export(bool) var printDebug: bool = false
export(Vector2) var firstShipStartPos: Vector2 = Vector2(112, 65)


onready var pathGenerator: PathGenerator = $PathGenerator
onready var wordsProvider: WordsProvider = $WordsProvider


func _ready():
	pass
	
	
func generateShips(numShips: int) -> Array:
	if (numShips <= 0):
		return []
		
	var windowWidth: int = OS.window_size.x
	
	var shipWords: Array = wordsProvider.takeWords(numShips)
	var shipsStartPos: Vector2 = firstShipStartPos
	var shipPositions: Array = pathGenerator.generatePathSegments(shipsStartPos)
	
	if (printDebug):
		_printFleetStats(numShips, shipPositions, shipWords)
		
	var preparedShips: Array = []
	for idx in range(numShips):
		var thisShipPosition: Vector2 = shipPositions[idx]
		var shipPath = pathGenerator.generatePathSegments(thisShipPosition)
		var textShip := TextShipScn.instance()
		textShip.prepare(shipWords[idx], thisShipPosition, shipPath)
		preparedShips.append(textShip)
	return preparedShips



func _printFleetStats(numShips: int, shipPositions: Array, shipWords: Array):
	print("\n")
	print("Sending in fleet: %s ships" % numShips)
	var shipsStartX := []
	for vectorPos in shipPositions.slice(0, numShips - 1):
		shipsStartX.append(vectorPos.x)
	print(Utils.joinToString(shipsStartX, " ", "%10.0d"))
	print(Utils.joinToString(shipWords, " ", "%10s"))
	print("\n")
