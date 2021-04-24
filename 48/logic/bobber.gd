extends Spatial

var moveDistance = 0.05;
var moveSpeed = 2;
var initialY;

var c = 0;

func _ready():
	initialY = transform.origin.y;

func _process(delta):
	c += delta;
	if(c > PI * 2): c = 0;
	transform.origin.y = initialY + sin(c * moveSpeed) * moveDistance;
