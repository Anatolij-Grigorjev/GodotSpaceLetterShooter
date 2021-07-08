extends Node
class_name WordsProvider
"""
Utility that loads a corpus of words to use in creating ships
Provides access to words list
"""
export(String, FILE, "*.txt") var externalFilePath: String setget setCorpusFilePath

var words: Array = []

"""
Array of tuples where item 1 is the word 
item 2 is useage frequency
"""
var wordsWithUseages: Array = []


func _ready():
	randomize()
	setCorpusFilePath(externalFilePath)
	
	
func setCorpusFilePath(newPath: String):
	externalFilePath = newPath
	if (not Utils.isEmptyString(newPath)):
		_initNewCorpusFromPath(newPath)
	
	
func _initNewCorpusFromPath(newCorpusFilePath: String):
	var fileText := _readFileText(newCorpusFilePath)
	words = fileText.split("\n", false)
	words.shuffle()
	wordsWithUseages = _initUnusedWordsArray(words)
	

func _readFileText(filePath: String) -> String:
	var file := File.new()
	var error := file.open(filePath, File.READ)
	if (error != OK):
		print("Error #%s opening file at path '%s'" % [error, filePath])
		return ""
	var content := file.get_as_text()
	file.close()
	return content


func takeWords(numNeeded: int) -> Array:
	var neededWords := []
	for idx in range(numNeeded):
		var wordFreqTuple = wordsWithUseages[idx]
		neededWords.push_back(wordFreqTuple[0])
		wordFreqTuple[1] += 1
	wordsWithUseages.sort_custom(self, "_sortByFreqAsc")
	
	return neededWords
	
	

func _initUnusedWordsArray(wordsArray: Array) -> Array:
	var result := []
	for word in wordsArray:
		result.push_back([word, 0])
	return result
	
	
func _sortByFreqAsc(tuple1, tuple2) -> bool:
	return tuple1[1] < tuple2[1]
