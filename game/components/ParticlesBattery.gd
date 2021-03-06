extends Node2D
class_name ParticlesBattery
"""
A container for one-shot particle systems that will use them one after the 
other in a rolling selection fashion

Can be used to always have a system available in cases where 
one system is still recharging while another can be fired
"""
signal activeParticlesWillEmit(activeParticles)
signal activeParticlesEmitted(activeParticles)

onready var particleSystems: Array = []


var numSystems: int = 0
var currentSystemIdx: int = 0


func _ready():
	currentSystemIdx = 0
	particleSystems = _filterParticleSystemsChildren()
	numSystems = particleSystems.size()


func _filterParticleSystemsChildren() -> Array:
	var systems = []
	for node in get_children():
		var particleSystem = node as Particles2D
		if (is_instance_valid(particleSystem)):
			systems.push_back(node)
	return systems
	

func fireNextParticleSystem() -> void:
	if (numSystems == 0):
		return
		
	var particles: Particles2D = particleSystems[currentSystemIdx]
	emit_signal("activeParticlesWillEmit", particles)
	particles.emitting = true
	emit_signal("activeParticlesEmitted", particles)
	currentSystemIdx = (currentSystemIdx + 1) % numSystems
	
