extends Spatial

onready var model = $model;
onready var rodTip = $"model/fishing_rod/rod-tip";
onready var animPlayer = $model/AnimationPlayer;

var bobber = preload("res://scenes/Bobber.tscn");
var bobberInstance;
var bobberInstancePosition;

var hasThrownLine = false;
var lineDistance = 0;
var lineDropSpeed = 2;

func _physics_process(delta):
	var offset = -PI * 1.75;
	var screen_pos = get_viewport().get_camera().unproject_position(model.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos)
	#model.rotation.y = -angle + offset;
	model.rotation.y = lerp_angle(model.rotation.y, -angle + offset, 0.15);

func _process(delta):
	if Input.is_action_just_pressed("Throw"):
		animPlayer.play("Cast");
	elif Input.is_action_just_released("Throw"):
		CatchLine();
	
	if(hasThrownLine):
		lineDistance += delta * lineDropSpeed;
		bobberInstance.global_transform.origin = bobberInstance.global_transform.origin.linear_interpolate(bobberInstancePosition, 0.1);

func ThrowLine():
	lineDistance = 0;
	
	var rayLength = 1000;
	var mousePos = get_viewport().get_mouse_position();
	var camera = get_viewport().get_camera();
	var from = camera.project_ray_origin(mousePos);
	var to = from + camera.project_ray_normal(mousePos) * rayLength;
	
	var spaceState = get_world().get_direct_space_state();
	var mouseWorldPos = spaceState.intersect_ray(from, to).position;
	bobberInstancePosition = Vector3(mouseWorldPos.x, 0, mouseWorldPos.z);
	
	bobberInstance = bobber.instance();
	bobberInstance.global_transform.origin = rodTip.global_transform.origin;
	get_tree().root.add_child(bobberInstance);
	
	hasThrownLine = true;
	print("threw line!");

func CatchLine():
	if(hasThrownLine):
		hasThrownLine = false;
		bobberInstance.queue_free();
		print("caught at a distance of")
		print(lineDistance);
	else:
		animPlayer.stop();
		animPlayer.seek(0, true);
