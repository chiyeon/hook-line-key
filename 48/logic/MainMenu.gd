extends Control

func _ready():
   $SplashHide.play("Hide");

func Play():
   $AnimationPlayer.play("Fade");   

func ChangeScene():
   get_tree().change_scene("res://scenes/intro_cutscene.tscn");
   Global.debugMode = false;
   Global.tutorialMode = true;