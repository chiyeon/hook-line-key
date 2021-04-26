extends Control

func _ready():
	# JUST IN CASE
	if(!Global.tutorialMode):
		get_node("/root/World/boat").disableLeftClick = false;

func _process(delta):
	if Input.is_action_just_pressed("Menu"):
		ToggleWindow();

func ToggleWindow():
	self.visible = !self.visible;
	
	if(self.visible):
		Global.isInputPaused = true;
	else:
		Global.isInputPaused = false;


func _on_Button_pressed():
	ToggleWindow();
