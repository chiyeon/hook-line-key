extends Control

var dialogueActive = false;

onready var animPlayer: AnimationPlayer = $AnimationPlayer;
onready var text: Label = $DialogueWindow/text

func ShowDialogue(message):
	# make sure only start dialogue if not in
	if(dialogueActive):
		return;
	
	# pause input so no accident inputs
	Global.isInputPaused = true;
	# update state
	dialogueActive = true;
	# drop down window
	animPlayer.play("ShowWindow");
	# update text
	text.text = message;


func AdvanceDialogue():
	HideDialogue();

func HideDialogue():
	Global.isInputPaused = false;
	animPlayer.play("HideWindow");
	dialogueActive = false;

func _process(delta):
	if Input.is_action_just_pressed("Throw") and dialogueActive and !animPlayer.is_playing():
		AdvanceDialogue();
	
	# debug
	if Input.is_key_pressed(KEY_T):
		ShowDialogue("monkey");
