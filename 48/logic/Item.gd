extends Resource

class_name Item

export(Image) var icon = null;
export(String) var name = "Item Name";
export(String) var description = "item description";


#var icon: Sprite;
#var name: String;
#var description: String;

#func _init(_name: String, _description: String)->void:
   #icon = _icon;
   #name = _name;
   #description = _description;