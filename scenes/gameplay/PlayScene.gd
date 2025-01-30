class_name PlayScene
extends MusicBeatScene

var keys = ["left","down","up","right"]
static var song = "senpai"
var notes = []
var spawnPoint:float
var earliestNoteCanBeHitAt = 60
var time:float = 0.0

# funny chart stuff
static var sName = ""
static var difficulty = "hard"
static var speed = 1.0

var generatedMusic = false
var inCutscene = false
var blueballed = false
var cdProgress = 0
var health = 0.5

func _ready():
	Conductor.songPosition = -1000000
	connect("b", onBeatHit)
	connect("s", onStepHit)
	initializeSong()

func initializeSong():
	var chartData = JSON.parse_string(FileAccess.get_file_as_string("res://assets/songs/"+song+"/data/charts.json"))
	var metaData = JSON.parse_string(FileAccess.get_file_as_string("res://assets/songs/"+song+"/data/meta.json"))
	Conductor.changeBPM(metaData["bpm"])
	sName = metaData["name"]
	speed = chartData["scrollSpeed"][difficulty]
	$Inst.stream = load("res://assets/songs/"+song+"/audio/Inst.ogg")
	$VoicesOpponent.stream = load("res://assets/songs/"+song+"/audio/VoicesO.ogg")
	$VoicesPlayer.stream = load("res://assets/songs/"+song+"/audio/VoicesP.ogg")
	for i in chartData["notes"][difficulty]:
		var oldNote:Note
		if notes.size() > 0:
			oldNote = notes[int(notes.size()-1)]
		else:
			oldNote = null
		var j = Note.new()
		j.prevNote = oldNote
		j.position.y = i["t"]
		j.time = i["t"]
		j.length = i.get_or_add("l",0.0)
		j.direction = int(i["d"]) % 4
		if i["d"] < 4:
			for k in $HUD/StrumLinePlayer.get_children():
				if k.name.contains("sn"+str(j.direction)):
					k.add_child(j)
		if i["d"] >= 4:
			for k in $HUD/StrumLineOpponent.get_children():
				if k.name.contains("sn"+str(j.direction)):
					k.add_child(j)
		if i["d"] < 9:
			notes.append(j)
		j.z_index += 1
		var susLength:float = j.length
		susLength = susLength/Conductor.stepCrochet
		for susNote in floor(susLength):
			oldNote = notes[int(notes.size())-1]
			var sustainNote:Note = Note.new()
			sustainNote.time = j.time + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet
			sustainNote.position.y = sustainNote.time
			sustainNote.direction = j.direction
			sustainNote.length = j.length
			if susNote > -1:
				sustainNote.firstInSus = false
			if susNote == floor(susLength)-1:
				sustainNote.lastInSus = true
			if i["d"] < 4:
				for k in $HUD/StrumLinePlayer.get_children():
					if k.name.contains("sn"+str(j.direction)):
						k.add_child(sustainNote)
			if i["d"] >= 4:
				for k in $HUD/StrumLineOpponent.get_children():
					if k.name.contains("sn"+str(j.direction)):
						k.add_child(sustainNote)
			notes.append(sustainNote)
		#var r = randi_range(0,7)
		#if r > 5:
			#j.noteType = "hurtNote"
		#j.applyNoteType()
	generatedMusic = true
	earliestNoteCanBeHitAt = earliestNoteCanBeHitAt*1.5
	Conductor.songPosition = Conductor.crochet*-4
	$CountdownTimer.start(Conductor.crochet/1000)

func _physics_process(delta: float):
	super._physics_process(delta)
	$HUD/Countdown2.text = str($CountdownTimer.time_left)
	if generatedMusic:
		Conductor.songPosition += (Conductor.offset + delta * 1000)*$Inst.pitch_scale
	$HUD/DebugInfo.text = str(Conductor.songPosition)
	
	keyShit()
	
	if notes.size() > 0:
		for daNote in notes:
			if is_instance_valid(daNote) && generatedMusic:
				daNote.position.y = (0.45 * (Conductor.songPosition - daNote.time) * daNote.get_parent().get_parent().speedModifier) * -speed
				if daNote.get_parent().get_parent().cpu && daNote.length == 0.0:
					if daNote.position.y < daNote.get_parent().global_position.y+10:
						daNote.frame = 0
						var dnP:StrumNote = daNote.get_parent()
						dnP.play(dnP.confirm)
						cpuNoteHit(daNote)
				if daNote.get_parent().get_parent().cpu && daNote.length > 0.0:
					if daNote.position.y < daNote.get_parent().global_position.y:
						daNote.frame = 0
						var dnP:StrumNote = daNote.get_parent()
						dnP.play(dnP.confirm)
						cpuNoteHit(daNote)
				if !daNote.get_parent().get_parent().cpu:
					if daNote.global_position.y < -20:
						noteMiss(daNote)
	
	time += delta
	
	#for i in $HUD/StrumLineOpponent.get_children():
		#if i.name.contains("sn"):
			#i.position.x = cos(time * ((i.get_index()+1)*2.5))+i.swagWidth*(i.get_index()+1)
			#i.position.y = i.swagWidth*0.55+sin(time * ((i.get_index()+1)*2.5))
	#for i in $HUD/StrumLinePlayer.get_children():
		#if i.name.contains("sn"):
			#i.position.x = i.swagWidth*-0.7+cos(time * ((i.get_index()+1)*2.5))+i.swagWidth*(i.get_index()+1)
			#i.position.y = i.swagWidth*0.55+sin(time * ((i.get_index()+1)*2.5))

func keyShit():
	for key in keys:
		var idx = keys.find(key,0)
		if !blueballed:
			if Input.is_action_just_pressed(key):
				for i in $HUD.get_children():
					if i.name.contains("StrumLine") && !i.cpu:
						var sn = i.get_child(idx)
						sn.frame = 0
						sn.play(sn.pressed)
			if Input.is_action_just_released(key):
				for i in $HUD.get_children():
					if i.name.contains("StrumLine") && !i.cpu:
						var sn = i.get_child(idx)
						sn.frame = 0
						sn.play(sn.unpressed)
			for daNote in notes:
				for i in $HUD.get_children():
					if i.name.contains("StrumLine") && !i.cpu:
						var sn:StrumNote = i.get_child(idx)
						var noteDistance = daNote.global_position.distance_to(sn.global_position)
						if Input.is_action_just_pressed(keys[idx]) && noteDistance > -2.5 && noteDistance < earliestNoteCanBeHitAt && daNote.direction == idx && daNote.length == 0.0:
							sn.frame = 0
							sn.play(sn.confirm)
							daNote.get_parent().get_parent().voiceTrack.volume_db = linear_to_db(1)
							goodNoteHit(daNote)
						if Input.is_action_pressed(keys[idx]) && noteDistance > -2.5 && noteDistance < earliestNoteCanBeHitAt/4 && daNote.direction == idx && daNote.length > 0.0:
							sn.frame = 0
							sn.play(sn.confirm)
							daNote.get_parent().get_parent().voiceTrack.volume_db = linear_to_db(1)
							goodNoteHit(daNote)
						if !Input.is_action_pressed(keys[idx]) && noteDistance < 0 && daNote.direction == idx && daNote.length > 0.0:
							noteMiss(daNote)

func noteCheck(keyP:bool, note:Note):
	if keyP:
		goodNoteHit(note)
	else:
		noteMiss(note)

func goodNoteHit(note:Note):
	note.onNoteHit()
	call("onPlayerNoteHit",note.direction, note.get_parent())
	notes.erase(note)
	note.queue_free()
	health += 0.05
	$HUD/OpponentHealthBar.value = 1-health
	$HUD/PlayerHealthBar.value = health

func cpuNoteHit(note:Note):
	note.onNoteHit()
	var dnP:StrumNote = note.get_parent()
	notes.erase(note)
	note.queue_free()
	await dnP.animation_finished
	dnP.play(dnP.unpressed)

func noteMiss(note:Note):
	note.get_parent().get_parent().voiceTrack.volume_db = linear_to_db(0.0001)
	notes.erase(note)
	note.queue_free()
	health -= 0.05
	$HUD/OpponentHealthBar.value = 1-health
	$HUD/PlayerHealthBar.value = health

func get_spawnpoint():
#	doing 720*2 for the sake of those REALLY long notes
	return 720*2 + ((720 / speed) + 122)

func onBeatHit(beat:int = curBeat):
	pass

func onStepHit(step:int = curStep):
	pass

# funny script stuff
func onPlayerNoteHit(direction:int, parent:StrumNote):
	pass

func _on_countdown_timer_timeout():
	cdProgress += 1
	match cdProgress:
		0:
			$CountdownTimer.start(Conductor.crochet/1000)
			$HUD/Countdown.text = "3"
		1:
			$CountdownTimer.start(Conductor.crochet/1000)
			$HUD/Countdown.text = "2"
		2:
			$CountdownTimer.start(Conductor.crochet/1000)
			$HUD/Countdown.text = "1"
		3:
			$CountdownTimer.start(Conductor.crochet/1000)
			$HUD/Countdown.text = "Go!"
		4:
			$HUD/Countdown.text = ""
			$Inst.play()
			$VoicesOpponent.play()
			$VoicesPlayer.play()
