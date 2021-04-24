extends Position3D

onready var impactSplash = $impact_splash;
onready var impactParticles = $impact_particles;

func _on_Timer_timeout():
	impactSplash.emitting = true;
	impactParticles.emitting = true;
