extends SongScript

var game = get_parent().get_parent()

func _ready():
	print("global script works!")

func cpuNoteHit(note):
	note.get_parent().position.y += 1

func playerNoteHit(note):
	note.get_parent().position.y += 1
