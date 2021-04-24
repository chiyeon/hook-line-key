extends Panel

onready var itemIcon: TextureRect = $"item-icon";
onready var itemName: Label = $"item-name";
onready var itemDescription: Label = $"item-description";

func HideScreen():
	self.visible = false;

func ShowScreen():
	self.visible = true;

func _on_Button_pressed():
	Global.isInputPaused = false;
	HideScreen();

func ShowItem(item):
	itemIcon.texture = item.icon;
	itemName.text = item.name;
	itemDescription.text = item.description;
	ShowScreen();

