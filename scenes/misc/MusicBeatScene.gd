class_name MusicBeatScene
extends Node2D

var lastBeat:float = 0
var lastStep:float = 0

var curStep:int = 0
var curBeat:int = 0

signal b
signal s

func _physics_process(delta: float):
	var oldStep:int = curStep
	
	updateCurStep()
	updateBeat()
	
	if oldStep != curStep && curStep > 0:
		stepHit()
	
func updateBeat():
	curBeat = floor(curStep/4)

func updateCurStep():
	var lastChange = Conductor.BPMChangeEvent.new()
	lastChange.stepTime = 0
	lastChange.songTime = 0
	lastChange.bpm = 0
	for i in Conductor.bpmChangeMap:
		if Conductor.songPosition >= i.songTime:
			lastChange = i
	curStep = lastChange.stepTime + floor(Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet

func stepHit():
	emit_signal("s")
	if curStep % 4 == 0:
		beatHit()

func beatHit():
	emit_signal("b")
