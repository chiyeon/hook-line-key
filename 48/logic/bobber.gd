extends Position3D

onready var impactSplash = $impact_splash;
onready var impactParticles = $impact_particles;

onready var bobber = $bobber;

var hidingBobber = false;
var cacheViewDistance;

func _on_Timer_timeout():
	impactSplash.emitting = true;
	impactParticles.emitting = true;

func HideBobber():
	hidingBobber = true;
	cacheViewDistance = bobber.moveDistance;

func ShowBobber():
	hidingBobber = false;

func _process(delta):
	if(hidingBobber):
		bobber.transform.origin = bobber.transform.origin.linear_interpolate(Vector3(0, -1.5, 0), 0.076);
