extends Position3D

onready var bubbles = $bubbles;
onready var splashes = $splashes;

func _on_Timer_timeout():
	bubbles.emitting = false;
	splashes.emitting = false;
