extends Position3D

onready var bubbles = [$bubbles_normal, $bubbles_rare, $bubbles_mythical];
onready var splashes: CPUParticles = $splashes;

func ShowHint():
	if(bubbles and splashes):
		for bubble in bubbles:
			bubble.emitting = true;
		splashes.emitting = true;
