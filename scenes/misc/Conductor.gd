class_name Conductor
extends Node

class BPMChangeEvent:
	var stepTime:int
	var songTime:float
	var bpm:float

static var bpm:float = 100
static var crochet:float = (60/bpm) * 1000
static var stepCrochet:float = crochet / 4
static var songPosition:float
static var lastSongPos:float
static var offset:float = 0

#originally 10 :fire:
static var safeFrames:int = 10
static var safeZoneOffset:float = (float(safeFrames)/60) * 1000

static var bpmChangeMap:Array[BPMChangeEvent] = []

#static func mapBPMChanges(song:Song.SwagSong):
	#bpmChangeMap = []
	#
	#var curBPM:float = song.bpm
	#var totalSteps:int = 0
	#var totalPos:float = 0
	#for i in song.notes.size()-1:
		#if song.notes[i].changeBPM && song.notes[i].bpm != curBPM:
			#curBPM = song.notes[i].bpm
			#var event = BPMChangeEvent.new()
			#event.stepTime = totalSteps
			#event.songTime = totalPos
			#event.bpm = curBPM
			#bpmChangeMap.push_back(event)
		#var deltaSteps:int = song.notes[i].lengthInSteps
		#totalSteps += deltaSteps
		#totalPos += ((60/curBPM) * 1000 / 4) * deltaSteps
		
static func changeBPM(newBPM:float):
	bpm = newBPM
	crochet = ((60/bpm) * 1000)
	stepCrochet = crochet / 4
