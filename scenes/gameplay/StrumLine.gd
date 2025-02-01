class_name StrumLine
extends Control

@export var noteSkin = "default"
@export var cpu = true
@export var keyCount = 4
@export var voiceTrack:AudioStreamPlayer
var speedModifier = 1

func _ready():
	var noteskinData:Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/shared/data/noteskins/"+noteSkin+".json"))
	for i in keyCount:
		var sn:StrumNote = StrumNote.new()
		sn.sprite_frames = load("res://assets/shared/images/noteskins/"+noteskinData["source"]+".xml")
		sn.unpressed = noteskinData["strumline"][str(i)][0]
		sn.pressed = noteskinData["strumline"][str(i)][1]
		sn.confirm = noteskinData["strumline"][str(i)][2]
		sn.offsetA = Vector2(noteskinData["offsets"]["unpressed"][0],noteskinData["offsets"]["unpressed"][1])
		sn.offsetB = Vector2(noteskinData["offsets"]["pressed"][0],noteskinData["offsets"]["pressed"][1])
		sn.offsetC = Vector2(noteskinData["offsets"]["confirm"][0],noteskinData["offsets"]["confirm"][1])
		sn.position.x = sn.swagWidth*i
		add_child(sn)
		if keyCount < 4:
			sn.position.x += sn.swagWidth/2*(4-keyCount)
		if keyCount > 4:
			sn.position.x -= sn.swagWidth/2*(keyCount-4)
		sn.play(sn.unpressed)
		sn.name = "sn"+str(i)+sn.get_parent().name
		sn.direction = i
		sn.scale.x = noteskinData["scale"][0]
		sn.scale.y = noteskinData["scale"][1]
	speedModifier = noteskinData["speedModifier"]
	if noteskinData["antialiasing"] == false:
		texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST
