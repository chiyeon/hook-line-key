# this may be the worst file i've ever written.

extends Spatial

# references
onready var model = $"boat-model/model"
onready var rodTip = $"boat-model/model/fishing-rod/model/rod-tip"
onready var animPlayer = $"boat-model/model/AnimationPlayer"

# fish hint -> bubbles to show where fish is
var fishHint = preload("res://scenes/FishHint.tscn");
var activeFishes = [];						# list of all active fish hints
var fishBobberMaxRange = 2;				# max range of a bobber being considered near a fish
var fishBobberMaxRangeHeight = 2;
var bobberNearActiveFish = false;		# is bobber in radius of fish hint
var fishNearBobberID: int;				# id of the fish that is near the bobber
onready var catchTimer = $"catch-timer";	# used to time the capture of fish
var isCatchingFish = false;				# if player is in act of reeling in;
var isInMinigame = false;
var clickCounter = 0;						# up every click, goes down based on rarity of fish
var clickGoal = 30;							# note that starts at HALF of goal
var clickStartPercentage = 0.55;			# % of click goal where counter starts
var numClicks = 0;							# used for alternating left/right click (using power)
var hintTimers = {};
var hints = {};
var isHoldingMouse = false;
var firstClickPosition;
var firstRightClickPosition;
var mouseDistance = 0;
var isRodReturningToPosition = false;
onready var fishingRod = $"boat-model/model/fishing-rod";
onready var tipRaycast: RayCast = $"boat-model/model/RayCast";
onready var mouseDragFirstIndicator = $"MouseFirstClick";
onready var mouseDragMoveIndicator = $"MouseFirstClick/MouseDragIndicator";
onready var bobberIndicator = $"bobber-indicator";

onready var rightClickIndicator = $"minigame/right-click";
onready var leftClickIndicator = $"minigame/left-click";
onready var fishingLine = $"../fishing-line";

# bobber instance
var bobber = preload("res://scenes/Bobber.tscn");
var bobberInstance;
var bobberInstancePosition;

var isBobberLocked = false;			# whether or not depth is static

var hasThrownLine = false;
var lineDistance = 0;					# length of fishing line. becomes static once bobber is locked
var lineDropSpeed = 6;
var maxDepth = 15;

# depth gage stuff
var depthGageMapScale = 3;
onready var depthGagePanel: Panel = $"depth-gage-master/depth-gage-panel";
onready var depthGageHookIndicator: Panel = $"depth-gage-master/depth-gage-panel/hook";
# list of all depth gage hints to destroy later
var depthGageHints = {};

onready var DepthGageHint = preload("res://scenes/DepthGageHint.tscn");

# minigame stuff
onready var minigamePanel: Control = $"minigame";
onready var clickIndicator: ProgressBar = $"minigame/progress-panel/ProgressBar";

# results screen for after catching fish
onready var resultsPanel: Panel = $result;

var rng = RandomNumberGenerator.new();

enum FishRarity {
	COMMON,
	RARE,
	MYTHICAL
}

func _ready():
	set_process_unhandled_input(true)
	rng.randomize();
	clickIndicator.max_value = clickGoal;
	clickCounter = clickGoal * clickStartPercentage;
	
	# tempoary assign
	#AddFish(FishRarity.COMMON, Vector3(rng.randi_range(3, 6) * pow(-1, rng.randi_range(1, 2)), rng.randi_range(-3, -maxDepth), rng.randi_range(4, 5) * pow(-1, rng.randi_range(1, 2))));
	#AddFish(FishRarity.RARE, Vector3(rng.randi_range(3, 6) * pow(-1, rng.randi_range(1, 2)), rng.randi_range(-3, -maxDepth), rng.randi_range(4, 5) * pow(-1, rng.randi_range(1, 2))));
	#AddFish(FishRarity.MYTHICAL, Vector3(rng.randi_range(3, 6) * pow(-1, rng.randi_range(1, 2)), rng.randi_range(-3, -maxDepth), rng.randi_range(4, 5) * pow(-1, rng.randi_range(1, 2))));


#func _physics_process(delta):
	# if line isn't thrown, rotate model around to face cursor
	#if !hasThrownLine and isHoldingMouse:
		#var offset = -PI * 1.75;
		#var screen_pos = get_viewport().get_camera().unproject_position(model.global_transform.origin)
		#var mouse_pos = get_viewport().get_mouse_position()
		#var angle = screen_pos.angle_to_point(mouse_pos)
		#model.rotation.y = -angle + offset;
		#model.rotation.y = lerp_angle(model.rotation.y, -angle + offset, 0.15);

func _process(delta):

	if isInMinigame:
		# update indicator
		clickIndicator.value = clickCounter;
		# decrement clickCounter based on rarity of fish
		clickCounter -= delta * (activeFishes[fishNearBobberID].rarity + 3);

		# shake camera depending on how close fish is
		var camera = get_viewport().get_camera();
		var shakeAmount = (1 - clickCounter/clickGoal) * 0.15;

		camera.rotation_degrees.z = rand_range(-1, 1) * shakeAmount;
		camera.h_offset = rand_range(-1, 1) * shakeAmount;
		camera.v_offset = rand_range(-1, 1) * shakeAmount;

		# cap at 0
		if(clickCounter <= 0):
			clickCounter = 0;
			CatchLine();

		# only alternating between right/left works
		if(pow(-1, numClicks) == 1):
			if Input.is_action_just_pressed("Throw"):
				clickCounter += 1;
				numClicks += 1;
				print(clickGoal - clickCounter + 1, " left");
				leftClickIndicator.rect_scale = Vector2(1, 1);
				rightClickIndicator.rect_scale = Vector2(1.2, 1.2);
		else:
			if Input.is_action_just_pressed("Reel"):
				clickCounter += 1;
				numClicks += 1;
				print(clickGoal - clickCounter + 1, " left");
				leftClickIndicator.rect_scale = Vector2(1.2, 1.2);
				rightClickIndicator.rect_scale = Vector2(1, 1);

		# if we hit goal minigame over
		if(clickCounter >= clickGoal):
			minigamePanel.visible = false;
			isInMinigame = false;
			CatchFish();
	else:
		if(Global.isInputPaused):
			return;

		if(isRodReturningToPosition):
			var targetRot = 0;
			fishingRod.rotation.x = move_toward(fishingRod.rotation.x, targetRot, 0.16);

			if(fishingRod.rotation.x == targetRot):
				isRodReturningToPosition = false;
				ThrowLine();

		if Input.is_action_just_pressed("Reel"):
			firstRightClickPosition = get_viewport().get_mouse_position();
		if Input.is_action_pressed("Reel"):
			var mousePos = get_viewport().get_mouse_position();

			var d = mousePos - firstRightClickPosition;
			firstRightClickPosition = mousePos;
			self.rotate_y(d.x * 0.01);
		
		if Input.is_action_just_pressed("Throw") and !hasThrownLine and !isBobberLocked and !isHoldingMouse:
			isHoldingMouse = true;
			mouseDistance = 0;
			firstClickPosition = get_viewport().get_mouse_position();
			bobberIndicator.visible = true;

			mouseDragFirstIndicator.visible = true;
			mouseDragFirstIndicator.rect_position = firstClickPosition;
		elif Input.is_action_just_released("Throw") and !hasThrownLine and !isBobberLocked and isHoldingMouse:
			isHoldingMouse = false;
			isRodReturningToPosition = true;
			bobberIndicator.visible = false;

			mouseDragFirstIndicator.visible = false;
		if Input.is_action_pressed("Throw") and !hasThrownLine and !isBobberLocked and isHoldingMouse:	# click to throw line
			#var screen_pos = get_viewport().get_camera().unproject_position(model.global_transform.origin)
			var mousePos = get_viewport().get_mouse_position()
			mouseDistance = firstClickPosition.distance_to(mousePos);

			mouseDragMoveIndicator.rect_global_position = mousePos;

			var angle = firstClickPosition.angle_to_point(mousePos)
			var offset = -PI * 0.75;
			var power = clamp(mouseDistance * 0.035, 0, PI * 0.5);
			tipRaycast.rotation.x = deg2rad(10) + power / 2;
			model.rotation.y = lerp_angle(model.rotation.y, -angle + offset - self.rotation.y, 0.15);
			fishingRod.rotation.x = lerp_angle(fishingRod.rotation.x, power, 0.15);

			var colPos = tipRaycast.get_collision_point();
			bobberIndicator.global_transform.origin = Vector3(colPos.x, 0, colPos.z);

		elif Input.is_action_just_pressed("Throw") and hasThrownLine and !isBobberLocked:	# click to lock bobber
			LockBobber();
		elif Input.is_action_just_pressed("Throw") and hasThrownLine and isBobberLocked and isCatchingFish:	# if fish bit, click to catch
			isInMinigame = true;
			minigamePanel.visible = true;
			print("started catching minigame click!");
		elif Input.is_action_just_pressed("Throw") and hasThrownLine and isBobberLocked and !isCatchingFish: # reel in
			CatchLine();

		#if Input.is_action_just_pressed("Reel"):
		#	CatchLine();
		
		# increase line distance after throwing, interpolate the bobber to the water spot
		if(hasThrownLine):
			# draw fishing line
			fishingLine.clear();
			fishingLine.begin(Mesh.PRIMITIVE_LINE_LOOP);
			fishingLine.add_vertex(rodTip.global_transform.origin);
			fishingLine.add_vertex(bobberInstance.global_transform.origin);
			fishingLine.end();

			# make hook go deeper at specified rate until max if bobber ISNT locked
			if(!isBobberLocked):
				if(lineDistance < maxDepth):
					lineDistance += delta * lineDropSpeed;
				else:
					lineDistance = maxDepth;
					LockBobber();
				depthGageHookIndicator.rect_position.y = (lineDistance + 1) * depthGageMapScale;
			
			# visually move bobber to water
			bobberInstance.transform.origin = bobberInstance.transform.origin.linear_interpolate(bobberInstancePosition, 0.1);

func ThrowLine():
	# reset line distance
	lineDistance = 0;
	
	# determine where player is throwing line
	var colPoint = to_local(tipRaycast.get_collision_point());
	bobberInstancePosition = Vector3(colPoint.x, 0.5, colPoint.z);
	
	# spawn bobber instance
	bobberInstance = bobber.instance();
	bobberInstance.global_transform.origin = rodTip.global_transform.origin;
	add_child(bobberInstance);

	# draw line
	fishingLine.visible = true;
	
	# throw line
	hasThrownLine = true;

	# show indicator on depth gage
	depthGageHookIndicator.visible = true;
	print("threw line!");

func CatchLine():
	if(hasThrownLine):
		# set near fish false
		bobberNearActiveFish = false;

		# cut line
		fishingLine.visible = false;

		# unlock bobber
		isBobberLocked = false;

		# turn off catch timer
		catchTimer.stop();

		# not catching anymore
		isCatchingFish = false;

		# click count
		clickCounter = clickGoal * clickStartPercentage;
		numClicks = 0;

		# no minigame
		isInMinigame = false;
		minigamePanel.visible = false;

		# reveal bobber
		bobberInstance.ShowBobber();

		# hide indicator for depth gage where hook is
		depthGageHookIndicator.visible = false;

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

	# check if player is throwing near a fish
	CheckBobberCloseToFish(bobberInstancePosition);

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
			hintTimer.wait_time = 6 + rng.randi_range(-2, 2);
			fishHintInstance.get_child(0).visible = true;
		FishRarity.RARE:
			hintTimer.wait_time = 10 + rng.randi_range(-3, 3);
			fishHintInstance.get_child(1).visible = true;
		FishRarity.MYTHICAL:
			hintTimer.wait_time = 15 + rng.randi_range(-5, 5);
			fishHintInstance.get_child(2).visible = true;
	
	add_child(hintTimer);
	hintTimer.start();
	
	var newFish = Fish.new(rarity, location);
	
	# add new fish object to list
	activeFishes.append(newFish);
	
	# get ID for caching dictionaries
	#var newFishID = activeFishes.find(newFish, 0);

	# add hint timer to dictionary (to reference outside)
	hintTimers[newFish] = hintTimer;
	hints[newFish] = fishHintInstance;

	# instance a depth gage hint
	var depthGageHint = DepthGageHint.instance();
	# set size for ? indicator
	depthGageHint.rect_size.y = fishBobberMaxRangeHeight * depthGageMapScale * 2;

	# show height hint
	depthGageHint.rect_position.y = -location.y * depthGageMapScale - fishBobberMaxRangeHeight * depthGageMapScale * 0.5;
	depthGagePanel.add_child(depthGageHint);

	depthGageHints[newFish] = depthGageHint;
	
	print("Created fish of ", FishRarity.keys()[rarity], " Rarity at ", location);

func RemoveFish(fishID):
	var fish = activeFishes[fishID];

	hintTimers.get(fish).queue_free();
	depthGageHints.get(fish).queue_free();
	hints.get(fish).queue_free();
	activeFishes.remove(fishID);

func CheckBobberCloseToFish(point):
	if(bobberNearActiveFish):
		return;
	for fish in activeFishes:
		var adjustedFishLocation = Vector3(fish.location.x, 0, fish.location.z);
		var xzDist = point.distance_to(adjustedFishLocation);
		var yDist = abs((-lineDistance) - fish.location.y);

		# if is close enough inc height
		if(xzDist < fishBobberMaxRange and yDist < fishBobberMaxRangeHeight):
			# set vars
			bobberNearActiveFish = true;
			fishNearBobberID = activeFishes.find(fish, 0);
			print("near (xz: ", xzDist ,"), (y: ", yDist, ") a fish ID of ", fishNearBobberID);

			# set timer
			catchTimer.wait_time = rng.randf_range(1.5, 3) + (fish.rarity + 1);
			catchTimer.connect("timeout", self, "BiteLine");
			catchTimer.start();

func BiteLine():
	print("Fish ", fishNearBobberID, " bit the line !");
	bobberInstance.HideBobber();
	isCatchingFish = true;
	var timer = Timer.new();
	timer.wait_time = 3;
	add_child(timer);
	timer.connect("timeout", self, "TryFailBite", [timer]);
	timer.start();

func TryFailBite(timer):
	timer.queue_free();
	if(isInMinigame):
		return;
	else:
		CatchLine();

func CatchFish():
	print("caught fish!");

	# reel in line
	CatchLine();

	# show results screen
	Global.isInputPaused = true;
	resultsPanel.ShowItem(activeFishes[fishNearBobberID].GetRandomCatch());

	# remove from active fishes array
	RemoveFish(fishNearBobberID);

	# check end game conditions
	if(activeFishes.size() == 0):
		# end game
		print("level clear!");
