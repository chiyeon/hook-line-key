extends TextureRect

func _ready():
	UpdateItem();

func UpdateItem():
	var i = int(get_name());
	print(i);
	if(!CollectedItems.items[i]):
		self.modulate = Color.black;
	else:
		self.modulate = Color.white;
