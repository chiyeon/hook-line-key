extends Node

var boat;

func _ready():
	boat = get_node("/root/World/boat");
	
	if(!Global.tutorialMode):
		if(boat.disableLeftClick):
			boat.disableLeftClick = false;
		if(Global.isInputPaused):
			Global.isInputPaused = false;

# runs to allow player to fish if they play again
func _process(delta):
	
		print(boat.disableLeftClick);
		print(Global.isInputPaused)
