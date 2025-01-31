extends Node

var ps = PlayScene.new()

func getGameSize():
	var result = get_window().content_scale_size
	return result

func setGameSize(x:int=1280,y:int=720):
	get_window().content_scale_size = Vector2i(x,y)
