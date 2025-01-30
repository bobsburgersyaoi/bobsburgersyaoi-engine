class_name StrumNote
extends AnimatedSprite2D
var swagWidth = 160 * 0.7
var direction = 0

var unpressed = ""
var pressed = ""
var confirm = ""

var offsetA = Vector2(0,0)
var offsetB = Vector2(0,0)
var offsetC = Vector2(0,0)

func _ready():
	centered = true
	apply_scale(Vector2(0.7,0.7))
	position.x += swagWidth*0.7
	position.y += swagWidth*0.55

func _process(delta: float):
	match animation:
		unpressed:
			offset = Vector2(offsetA.x,offsetA.y)
		pressed:
			offset = Vector2(offsetB.x,offsetB.y)
		confirm:
			offset = Vector2(offsetC.x,offsetC.y)
