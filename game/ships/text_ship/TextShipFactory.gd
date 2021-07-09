extends Node
"""
Facility creates and configures text ship instances in a 
background thread to make them ready for next wave participation
"""
const TextShipScn = preload("res://ships/text_ship/TextShip.tscn")

export(bool) var printDebug: bool = false


onready var pathGenerator: PathGenerator = $PathGenerator
onready var wordsProvider: WordsProvider = $WordsProvider


func setShipsWordsCorpusPath(filePath: String):
	var corpusResourcePath = "res://"
	if (Utils.isEmptyString(filePath)):
		corpusResourcePath += GameConfig.DEFAULT_WORDS_CORPUS_PATH
		print("No corpus file supplied, using default '%s'..." % GameConfig.DEFAULT_WORDS_CORPUS_PATH)
	else:
		corpusResourcePath += filePath
	print("Using corpus path '%s'..." % corpusResourcePath)
	$WordsProvider.externalFilePath = corpusResourcePath
	
	
	
func generateShips(waveSpec: SceneWaveSpec) -> Array:
	if (waveSpec.numShips <= 0):
		return []
		
	var windowWidth: int = OS.window_size.x
	
	var shipWords: Array = wordsProvider.takeWords(waveSpec.numShips)
	var shipsStartPos: Vector2 = waveSpec.firstShipStartPos
	var shipPositions: Array = pathGenerator.generatePathSegments(shipsStartPos)
	
	if (printDebug):
		_printFleetStats(waveSpec.numShips, shipPositions, shipWords, waveSpec.shipTypes)
		
	var preparedShips: Array = []
	for idx in range(waveSpec.numShips):
		var thisShipPosition: Vector2 = shipPositions[idx]
		var shipPath = pathGenerator.generatePathSegments(thisShipPosition)
		var textShip := TextShipScn.instance()
		textShip.prepare(
			shipWords[idx], 
			thisShipPosition, 
			shipPath, 
			waveSpec.shipTypes[idx]
		)
		preparedShips.append(textShip)
	if (printDebug):
		print("Built %s ship(-s)..." % preparedShips.size())
	return preparedShips



func _printFleetStats(numShips: int, shipPositions: Array, shipWords: Array, shipTypes: Array):
	print("\n")
	print("Sending in fleet: %s ships" % numShips)
	var shipsStartX := []
	for vectorPos in shipPositions.slice(0, numShips - 1):
		shipsStartX.append(vectorPos.x)
	print(Utils.joinToString(shipsStartX, " ", "%10.0d"))
	print(Utils.joinToString(shipWords, " ", "%10s"))
	print(Utils.joinToString(shipTypes, " ", "%10s"))
	print("\n")
