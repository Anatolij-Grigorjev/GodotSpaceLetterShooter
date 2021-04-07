extends Node
class_name WordsProvider
"""
Utility that loads a corpus of words to use in creating ships
Provides access to words list
"""
export(String, FILE, "*.txt") var filePath: String

var words: Array = []

func _ready():
	randomize()
	var fileText := _readFileText(filePath)
	words = fileText.split("\n", false)
	words.shuffle()
	

func _readFileText(filePath: String) -> String:
	var file := File.new()
	var error := file.open(filePath, File.READ)
	if (error != OK):
		print("Error opening file: %s" % error)
		return ""
	var content := file.get_as_text()
	file.close()
	return content


func takeWords(numNeeded: int) -> Array:
	var neededWords := words.slice(0, numNeeded - 1)
	words.shuffle()
	return neededWords
