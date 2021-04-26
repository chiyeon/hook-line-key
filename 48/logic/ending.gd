extends Node2D

func _ready():
	$AnimationPlayer.play("Play");

func ShowEndScreen():
	$Control/End.visible = true;

func MainMenu():
	Global.tutorialMode = false;
	get_tree().change_scene("res://scenes/mainmenu.tscn");


func _on_Button_pressed():
	MainMenu();
