extends Panel

onready var itemIcon: TextureRect = $"item-icon";
onready var itemName: Label = $"item-name";
onready var itemDescription: Label = $"item-description";

func HideScreen():
	self.visible = false;

func ShowScreen():
	self.visible = true;
	$AudioUp.play();

func _on_Button_pressed():
	Global.isInputPaused = false;
	get_node("/root/World/boat").tutorialFlip = true;
	$AudioDdown.play();
	HideScreen();

func ShowItem(item):
	itemIcon.texture = item.icon;
	itemName.text = item.name;
	itemDescription.text = item.description;
	ShowScreen();

