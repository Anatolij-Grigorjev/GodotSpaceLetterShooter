class_name TextShipModel
"""
Property values required to instantiate a text ship of the id specified here
"""

var id: String
var model: PackedScene
var baseSpeed: float
var shieldHP: int
var shootAffinity: int


func _init(id: String, modelPath: String, speed: float, shieldHP: int = 0, shootAffinity: int = 0):
	self.id = id
	self.model = load(modelPath)
	self.baseSpeed = speed
	self.shieldHP = max(0, shieldHP)
	self.shootAffinity = max(0, shootAffinity)
