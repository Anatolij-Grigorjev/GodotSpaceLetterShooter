class_name WeightedItems
"""
Textual items data with unequal weights.
Allows picking an item, which increases the weight of others
"""
const DISABLE_ITEM_WEIGHT = 0.0

var itemWeights: Dictionary = {}
var weightUnitValue: float = 0.0


func _init(initialWeights: Dictionary):
	if (initialWeights):
		itemWeights = initialWeights.duplicate(true)
		weightUnitValue = _calcChanceOfWeightUnit()
	else:
		itemWeights = {}


func disableItem(item: String):
	itemWeights[item] = DISABLE_ITEM_WEIGHT
	weightUnitValue = _calcChanceOfWeightUnit()
	

func setItemWeight(item: String, weight: int):
	itemWeights[item] = weight
	weightUnitValue = _calcChanceOfWeightUnit()
	
	
func isItemDisabled(item: String) -> bool:
	return not itemWeights.has(item) or itemWeights[item] == DISABLE_ITEM_WEIGHT


func pickRandomWeighted() -> String:
	var randomThrow := randi() % 100
	var remainingUncertainty := float(randomThrow)
	var pickedItem = null
	for item in itemWeights:
		var itemWeight: float = itemWeights[item]
		remainingUncertainty -= (itemWeight * weightUnitValue)
		if (remainingUncertainty < 0.0):
			pickedItem = item
			break
	_increaseEnabledItemWeightsExcept(pickedItem)
	return pickedItem
	


func _calcChanceOfWeightUnit() -> float:
	var allWeightsArray: Array = itemWeights.values()
	var sum := 0.0
	for weight in allWeightsArray:
		sum += weight
	return 100.0 / (max(sum, 1.0))
	
	

func _increaseEnabledItemWeightsExcept(ignoreItem: String):
	for item in itemWeights:
		var weight = itemWeights[item]
		if (item == ignoreItem):
			continue
		elif (isItemDisabled(item)):
			continue
		else:
			itemWeights[item] = itemWeights[item] + 1.0
	weightUnitValue = _calcChanceOfWeightUnit()
	
	
func _to_string() -> String:
	return "%s" % itemWeights 
