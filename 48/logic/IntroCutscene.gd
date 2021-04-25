extends Node2D

func _ready():
	$AnimationPlayer.play("Intro");  

func Play():
	get_tree().change_scene("res://scenes/test.tscn");
