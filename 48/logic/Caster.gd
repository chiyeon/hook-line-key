extends Spatial

# references
onready var model = $"boat-model/model"
onready var rodTip = $"boat-model/model/fishing_rod/rod-tip"
onready var animPlayer = $"boat-model/model/AnimationPlayer"

# fish hint -> bubbles to show where fish is
var fishHint = preload("res://scenes/FishHint.tscn");
var activeFishes = [];						# list of all active fish hints
var fishBobberMaxRange = 1;				# max range of a bobber being considered near a fish
var bobberNearActiveFish = false;		# is bobber in radius of fish hint
#var fishNearBobberID: int;				# id of the fish that is near the bobber
onready var catchTimer = $"catch-timer";	# used to time the capture of fish

# bobber instance
var bobber = preload("res://scenes/Bobber.tscn");
var bobberInstance;
var bobberInstancePosition;

var isBobberLocked = false;			# whether or not depth is static

var hasThrownLine = false;
var lineDistance = 0;					# length of fishing line. becomes static once bobber is locked
var lineDropSpeed = 2;
var maxDepth = 10;

var rng = RandomNumberGenerator.new();

enum FishRarity {
	COMMON,
	RARE,
	MYTHICAL
}

func _ready():
	rng.randomize();
	
	# tempoary assign
	AddFish(FishRarity.COMMON, Vector3(rng.randi_range(3, 6) * pow(-1, rng.randi_range(1, 2)), rng.randi_range(-1, -10), rng.randi_range(4, 5) * pow(-1, rng.randi_range(1, 2))));

func _physics_process(delta):
	# if line isn't thrown, rotate model around to face cursor
	if !hasThrownLine:
		var offset = -PI * 1.75;
		var screen_pos = get_viewport().get_camera().unproject_position(model.global_transform.origin)
		var mouse_pos = get_viewport().get_mouse_position()
		var angle = screen_pos.angle_to_point(mouse_pos)
		#model.rotation.y = -angle + offset;
		model.rotation.y = lerp_angle(model.rotation.y, -angle + offset, 0.15);

func _process(delta):
	if Input.is_action_just_pressed("Throw") and !hasThrownLine:
		animPlayer.play("Cast");
	elif Input.is_action_just_pressed("Throw") and hasThrownLine and !isBobberLocked:
		LockBobber();
	elif Input.is_action_just_pressed("Throw") and hasThrownLine and isBobberLocked:
		CatchLine();
	
	# increase line distance after throwing, interpolate the bobber to the water spot
	if(hasThrownLine):
		# make hook go deeper at specified rate until max if bobber ISNT locked
		if(!isBobberLocked):
			if(lineDistance < maxDepth):
				lineDistance += delta * lineDropSpeed;
			else:
				lineDistance = maxDepth;
				LockBobber();
		
		# visually move bobber to water
		bobberInstance.global_transform.origin = bobberInstance.global_transform.origin.linear_interpolate(bobberInstancePosition, 0.1);

func ThrowLine():
	# reset line distance
	lineDistance = 0;
	
	# determine where player is throwing line
	var rayLength = 1000;
	var mousePos = get_viewport().get_mouse_position();
	var camera = get_viewport().get_camera();
	var from = camera.project_ray_origin(mousePos);
	var to = from + camera.project_ray_normal(mousePos) * rayLength;
	
	var spaceState = get_world().get_direct_space_state();
	var mouseWorldPos = spaceState.intersect_ray(from, to).position;
	bobberInstancePosition = Vector3(mouseWorldPos.x, 0, mouseWorldPos.z);

	# check if player is throwing near a fish
	CheckBobberCloseToFish(bobberInstancePosition);
	
	# spawn bobber instance
	bobberInstance = bobber.instance();
	bobberInstance.global_transform.origin = rodTip.global_transform.origin;
	get_tree().root.add_child(bobberInstance);
	
	# throw line
	hasThrownLine = true;
	print("threw line!");

func CatchLine():
	if(hasThrownLine):
		# set near fish false
		bobberNearActiveFish = false;

		# unlock bobber
		isBobberLocked = false;

		# turn off catch timer
		catchTimer.stop();

		# catch, delete bobber
		hasThrownLine = false;
		bobberInstance.queue_free();
		print("reeled line in!")
	else:
		animPlayer.stop();
		animPlayer.seek(0, true);

func LockBobber():
	isBobberLocked = true;
	print("Bobber locked at a depth of ", lineDistance);

func AddFish(rarity, location):
	# create instance of bubbling hint
	var fishHintInstance = fishHint.instance();
	add_child(fishHintInstance);
	fishHintInstance.global_transform.origin = Vector3(location.x, 0, location.z);
	
	# create timer for the hint to loop
	var hintTimer = Timer.new();
	hintTimer.connect("timeout", fishHintInstance, "ShowHint");
	
	match(rarity):
		FishRarity.COMMON:
			hintTimer.wait_time = 10;
			fishHintInstance.get_child(0).visible = true;
		FishRarity.RARE:
			hintTimer.wait_time = 15;
			fishHintInstance.get_child(1).visible = true;
		FishRarity.MYTHICAL:
			hintTimer.wait_time = 20;
			fishHintInstance.get_child(2).visible = true;
	
	add_child(hintTimer);
	hintTimer.start();
	
	# add new fish object to list
	activeFishes.append(Fish.new(rarity, location));
	
	print("Created fish of ", FishRarity.keys()[rarity], " Rarity at ", location);

func CheckBobberCloseToFish(point):
	if(bobberNearActiveFish):
		return;
	for fish in activeFishes:
		var adjustedFishLocation = Vector3(fish.location.x, 0, fish.location.z);
		var dist = point.distance_to(adjustedFishLocation);
		if(dist < fishBobberMaxRange):
			# set vars
			bobberNearActiveFish = true;
			var fishID = activeFishes.find(fish, 0);
			print("near (", dist ,") a fish ID of ", fishID);

			# set timer
			catchTimer.wait_time = rng.randf_range(1, 2) * fish.rarity;
			catchTimer.start();

func CatchFish(fishID):
	print("Caught fish ", fishID, "!");

