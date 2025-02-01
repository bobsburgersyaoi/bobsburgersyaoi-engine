class_name Note
extends AnimatedSprite2D

var swagWidth = 160 * 0.7
var time = 0.0
var direction = 0
var length = 0.0
var noteType = ""

var prevNote:Note
var firstInSus:bool = true
var lastInSus:bool = false

func _ready():
	if prevNote == null:
		prevNote = self
	self.prevNote = prevNote
	var noteskinData = JSON.parse_string(FileAccess.get_file_as_string("res://assets/shared/data/noteskins/"+get_parent().get_parent().noteSkin+".json"))
	sprite_frames = load("res://assets/shared/images/noteskins/"+noteskinData["source"]+".xml")
	centered = true
	play(noteskinData["notes"][str(direction)][0])
	if length > 0.0 && prevNote != null:
		play(noteskinData["notes"][str(direction)][0])
		scale.y = 1.0
		if length > 0.0 && !firstInSus:
			play(noteskinData["notes"][str(direction)][1])
			scale.y = (Conductor.stepCrochet / 100 * 1.5 * PlayScene.speed)
		if lastInSus:
			play(noteskinData["notes"][str(direction)][2])
			prevNote.scale.y = 1.0
	
func applyNoteType():
	match noteType:
		"hurtNote":
			modulate.g = 0
			modulate.b = 0

func onNoteHit():
	match noteType:
		"hurtNote":
			var tweenfromabutt = get_tree().create_tween()
			tweenfromabutt.set_trans(Tween.TRANS_CUBIC)
			tweenfromabutt.set_ease(Tween.EASE_IN_OUT)
			tweenfromabutt.tween_property(get_parent(),"rotation",get_parent().rotation+0.1,0.4)
