extends Node

var UpgradeThresholds = [3, 4, 5]
var currentUpgradeThreshold = 0;
var currentNumCatches: float = 0;

var upgradeProgressBar = false;

onready var tween = $"LevelProgress/Tween"
onready var levelProgressBar = $"LevelProgress"

var caster;

func Setup(_caster):
	caster = _caster;
	levelProgressBar.max_value = UpgradeThresholds[currentUpgradeThreshold];
	levelProgressBar.value = 0;

# to completely set value
func FinishTween(object, key):
	levelProgressBar.value = currentNumCatches;

	# check if we have to restart
	if(upgradeProgressBar):

		# disable
		upgradeProgressBar = false;

		# reset catch counter
		currentNumCatches = 0;
		# increase # of required catches for next time
		currentUpgradeThreshold += 1;
		# update that on progress bar
		levelProgressBar.max_value = UpgradeThresholds[currentUpgradeThreshold];
		# set bar back to 100% to animate tween downards
		levelProgressBar.value = levelProgressBar.max_value;

		# messages
		#if(UpgradeThresholds[currentUpgradeThreshold] == 5):
			#get_node("/root/World/DialoguePanel").ShowDialogue("The keys must be at the bottom of this lake.");

		# animating bar moving back
		tween.interpolate_property(levelProgressBar, "value", levelProgressBar.value, currentNumCatches, 2, Tween.TRANS_SINE, Tween.EASE_OUT);
		tween.start();

func AddCatch():
	# add to catches
	currentNumCatches += 1;

	# animate bar
	tween.interpolate_property(levelProgressBar, "value", levelProgressBar.value, currentNumCatches, 1, Tween.TRANS_SINE, Tween.EASE_OUT);
	tween.connect("tween_completed", self, "FinishTween")
	tween.start();

	# if we met the goal
	if(currentNumCatches >= UpgradeThresholds[currentUpgradeThreshold]):
		# increase depth
		caster.UpgradeDepth();
		print ("Level up! Depth expanded");
		upgradeProgressBar = true;
		
