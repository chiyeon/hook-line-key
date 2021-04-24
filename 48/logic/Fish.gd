extends Object

class_name Fish

var rarity: int;
var location: Vector3;
var rng = RandomNumberGenerator.new();

func _init(_rarity: int, _location: Vector3)->void:
	rarity = _rarity;
	location = _location;
	rng.randomize();

func GetRandomCatch():

	var key = rng.randf()
	var catch = null;

	match(rarity):
		0: # normal
			if(key > 0.95):	# godly drop 5%
				catch = load("res://resources/items/common-catch/Trophy.tres");
			elif(key > 0.85):	# good drop 10%
				catch = load("res://resources/items/common-catch/GoldFish.tres");
			elif(key > 0.35):	# ok drop 50%
				var c = rng.randf();
				if(c > 0.5):
					catch = load("res://resources/items/common-catch/bluegill.tres");
				else:
					catch = load("res://resources/items/common-catch/yellowfin-tuna.tres");
			elif(key >= 0):	# bad drop 35%
				var c = rng.randf();
				if(c > 0.75):
					catch = load("res://resources/items/common-catch/soda-can.tres");
				elif(c > 0.5):
					catch = load("res://resources/items/common-catch/stinky-seaweed.tres");
				elif(c > 0.25):
					catch = load("res://resources/items/common-catch/driftwood.tres");
				else:
					catch = load("res://resources/items/common-catch/stinky-fish.tres");
			pass;
		1: # rare
			if(key > 0.95):	# godly drop 5%
				catch = load("res://resources/items/rare-catch/unity-pro-license.tres");
			elif(key > 0.85):	# good drop 10%
				catch = load("res://resources/items/rare-catch/24kFish.tres");
			elif(key > 0.35):	# ok drop 50%
				var c = rng.randf();
				if(c > 0.66):
					catch = load("res://resources/items/rare-catch/eel.tres");
				elif(c > 0.33):
					catch = load("res://resources/items/rare-catch/Sturgeon.tres");
				else:
					catch = load("res://resources/items/rare-catch/lamprey.tres");
			elif(key >= 0):	# bad drop 35%
				var c = rng.randf();
				if(c > 0.75):
					catch = load("res://resources/items/rare-catch/ConcertTicket.tres");
				elif(c > 0.5):
					catch = load("res://resources/items/rare-catch/Dictionary.tres");
				elif(c > 0.25):
					catch = load("res://resources/items/rare-catch/hydroflask.tres");
				else:
					catch = load("res://resources/items/rare-catch/expensive-check.tres");
		2: # mythical
			if(key > 0.95):	# godly drop 5%
				catch = load("res://resources/items/mythical-catch/bbestitem.tres");
			elif(key > 0.85):	# good drop 10%
				catch = load("res://resources/items/mythical-catch/secondbestitem.tres");
			elif(key > 0.35):	# ok drop 50%
				var c = rng.randf();
				if(c > 0.5):
					catch = load("res://resources/items/mythical-catch/iridescent-shark.tres");
				else:
					catch = load("res://resources/items/mythical-catch/shad.tres");
			elif(key >= 0):	# bad drop 35%
				var c = rng.randf();
				if(c > 0.5):
					catch = load("res://resources/items/mythical-catch/ancient-bow.tres");
				else:
					catch = load("res://resources/items/mythical-catch/smartphone.tres");
	return catch;
