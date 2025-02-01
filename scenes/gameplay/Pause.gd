extends Node2D

func _ready():
	pass

func _process(delta: float):
	if Input.is_action_just_pressed("accept"):
		get_tree().paused = not get_tree().paused
		$Menu/PauseTxt.visible = get_tree().paused
