extends Node

var UpgradeThresholds = [4, 5, 6]
var currentUpgradeThreshold = 0;
var currentNumCatches = 0;

onready var levelProgressBar = $"LevelProgress"

var caster;

func Setup(_caster):
   caster = _caster;
   levelProgressBar.max_value = UpgradeThresholds[currentUpgradeThreshold];
   levelProgressBar.value = 0;

func AddCatch():
   # add to catches
   currentNumCatches += 1;
   #update progres bar
   levelProgressBar.value = currentNumCatches;

   # if we met the ggoal
   if(currentNumCatches >= UpgradeThresholds[currentUpgradeThreshold]):
	   # reset catch counter
	   currentNumCatches = 0;
	   # increase # of required catches for next time
	   currentUpgradeThreshold += 1;
	   # update that on progress bar
	   levelProgressBar.max_value = UpgradeThresholds[currentUpgradeThreshold];
	   #reset progress bar
	   levelProgressBar.value = 0;
	   # increase maxDpeth
	   caster.maxDepth += 15;
