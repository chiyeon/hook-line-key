extends Node

onready var timer: Timer = $Timer;

var Dialogue;
var Messages = [
	"Left click to advance dialogue",
	"Right click + Drag to look around",
	"Left click + Drag to fish",
	"Left click again or wait to keep the hook in place",
	"The depth of the hook is shown on the left"
]
var dialogueState = 0;

func _on_Timer_timeout():
	print("HI");
	Dialogue = get_node("/root/World/DialoguePanel");
	Dialogue.ShowDialogue(Messages[dialogueState]);
	dialogueState += 1;

	if(dialogueState == 1):
		timer.wait_time = 3;
	if(dialogueState == 3):
		timer.wait_time = 5;
	if(dialogueState == 4):
		timer.wait_time = 3;

func _process(delta):
	if Input.is_action_just_pressed("Throw") and timer.is_stopped() and !Dialogue.dialogueActive:
		timer.start();
