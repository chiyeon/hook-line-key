extends Object

class_name Fish

var rarity: int;
var location: Vector3;

func _init(_rarity: int, _location: Vector3)->void:
	rarity = _rarity;
	location = _location;
