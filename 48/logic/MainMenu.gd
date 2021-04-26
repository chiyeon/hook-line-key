extends Control

func _ready():
	$SplashHide.play("Hide");

func Play():
	$AnimationPlayer.play("Fade");   

func ChangeScene():
	if(Global.tutorialMode):
		get_tree().change_scene("res://scenes/intro_cutscene.tscn");
	else:
		get_tree().change_scene("res://scenes/test.tscn");

func OpenCollectables():
	$Menu.visible = false;
	$Collectables.visible = true;

func HideCollectables():
	$Menu.visible = true;
	$Collectables.visible = false;

func _on_Button_pressed():
	HideCollectables();


func _on_collectablesbutton_pressed():
	OpenCollectables();
