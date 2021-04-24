extends Spatial

var moveDistance = 0.075;
var initialY;

var c = 0;

func _ready():
	initialY = global_transform.origin.y;

func _process(delta):
	c += delta;
	if(c > PI * 2): c = 0;
	global_transform.origin.y = initialY + sin(c) * moveDistance;
