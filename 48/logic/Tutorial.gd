# my forefathers are looking down disappointed at this one :sob:
extends Node

onready var timer: Timer = $Timer;
onready var caster = get_node("../boat");

var Dialogue;
var Messages = [
	"My keys must be at the bottom!",#0
	"Right click n Drag to look around",#1
	"Left click n Drag to aim, let go to cast",#2
	"Left click again or wait to lock the hook in place",#3
	"The depth of the hook is shown on the left",#4
	"The usable range of your rod is in dark blue",#5
	"Left click again to reel in",#6
	"Find fish by looking for splashes or bubbles",#7
	"Different colored bubbles take longer to show again",#8
	"Use the depth gage to know where to lock the hook",#9
	"Fish hide in the yellow '?' zone",#10
	"All '?' zones are identical per fish",#11
	"So with multiple fish you'll have to guess!",#12
	"Try to catch the fish over there.",#13
	"If you're at the right depth and location...",#14
	"The red bobber will dip below the water when a fish bites!",#15
	"Left click when you see the bobber dip",#16
	"Fish take no longer than 5 seconds to bite",#17
	"If the bobber doesn't dip by then, wrong depth! Now try",#18
	"You just caught something!",
	"Items are stored instantly. There are many to collect",
	"You also upgraded your fishing rod!",
	"The top bar shows the fish needed for an upgrade",
	"Each upgrade lets you go deeper and deeper.",
	"Now go catch some fish!"
]
var dialogueState = -1;
var waiting = false;
var waiting2 = false;

var waiting3 = false;

func _ready():
	if(!Global.tutorialMode):
		queue_free();
	
	#caster.disableLeftClick = true;

func _on_Timer_timeout(debug=false):
	Dialogue = get_node("/root/World/DialoguePanel");
	dialogueState += 1;
	if(dialogueState >= Messages.size()):
		return;
	if(debug and Dialogue.dialogueActive):
		Dialogue.HideDialogue();
	Dialogue.ShowDialogue(Messages[dialogueState], debug);

	if(dialogueState == 1):
		timer.wait_time = 3; 
	if(dialogueState == 2):
		timer.wait_time = 0.35;
	if(dialogueState == 3):
		caster.disableLeftClick = false;
		timer.wait_time = 3;
	if(dialogueState == 4):
		caster.disableLeftClick = true;
		timer.wait_time = 1;
	if(dialogueState == 6):
		caster.disableLeftClick = false;
	if(dialogueState == 7):
		caster.disableLeftClick = true;
		timer.wait_time = 0.35;
	if(dialogueState == 8):
		timer.wait_time = 3;
	if(dialogueState == 9):
		timer.wait_time = 0.35;
	#if(dialogueState == 2):
		#waiting = true;
	if(dialogueState == 7):
		caster.AddFish(0, Vector3(3, -6, 3));
	if(dialogueState == 12):
		timer.wait_time = 2;
	if(dialogueState == 13):
		timer.wait_time = 0.35;
	if(dialogueState == 18):
		caster.disableLeftClick = false;

func _process(delta):

	if Input.is_action_just_pressed("debug") and Global.debugMode:
		_on_Timer_timeout(true);

	if(dialogueState == 18):
		if(!caster.tutorialFlip):
			return;
		else:
			_on_Timer_timeout();

	if Input.is_action_just_pressed("Throw") and timer.is_stopped() and !Dialogue.dialogueActive:
		if(dialogueState == 3 || dialogueState == 6):
			if(waiting):
				waiting2 = true;
				return;
			else:
				waiting = true;
				return;
			
		timer.start();
		print("next start");

	if Input.is_action_just_released("Throw") and waiting2:
		waiting = false;
		waiting2 = false;
		timer.start();
		print("alt_start");


