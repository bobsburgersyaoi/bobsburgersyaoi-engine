@tool
class_name Alphabet
extends Control

var delay:float = 0.05
var paused:bool = false
var cb:AnimatedSprite2D
var cbChecked:bool = false
var icon:Sprite2D

@export var text:String = ""
@export var targetY:float = 0
@export var isMenuItem:bool = false
@export var optionItem:bool = false
@export var iconItem:bool = false

var _finalText:String = ""
var _curText:String = ""

var widthOfWords:float = 1280

var yMulti:float = 1

# "custom shit"
# "amp, backslash, question mark, apostrophy, comma, angry faic, period"
var lastSprite:AlphaCharacter
var xPosResetted:bool = false
var lastWasSpace:bool = false

var splitWords:Array[String] = []
@export var isBold:bool = false

class AlphaCharacter extends AnimatedSprite2D:
	var alphabet:String = "abcdefghijklmnopqrstuvwxyz"
	var numbers:String = "1234567890"
	var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?"
	var row:int = 0
	
	func new(x:float, y:float):
		var texPath = "res://assets/shard/images/alphabet.xml"
		var tex = load(texPath)
		sprite_frames = tex
	
	func createBold(letter:String):
		if alphabet.contains(letter.to_lower()):
			play(letter.to_upper()+" bold")
		#var nA = numbers.split("")
		#var nB = []
		#nB.assign(nA)
		if numbers.contains(letter):
			play(letter+" bold")
	
	func createLetter(letter:String):
		var letterCase:String = "lowercase"
		if letter.to_lower() != letter:
			letterCase = "capital"
		if alphabet.contains(letter.to_lower()):
			play(letter+" "+letterCase)
		if numbers.contains(letter):
			play(letter)
		
		position.y = 55 - sprite_frames.get_frame_texture(animation,0).get_height()
		position.y += row * 60
	
	func createSymbol(letter:String):
		match letter:
			".":
				play("period")
				position.y += 50
			"'":
				play("apostraphie")
				position.y -= 0
			"?":
				play("question mark")
			"!":
				play("exclamation point")

func _ready():
	#self.new(position.x,position.y,text,isBold,false)
	pass

func new(x:float = 0, y:float = 0, text:String = "", bold:bool = false, checkbox:bool = false,hasIcon:bool = false,typed:bool = false):
	_finalText = text
	self.text = text
	self.isBold = bold
	self.optionItem = checkbox
	self.iconItem = hasIcon
	
	if text != "":
		#if typed:
			#startTypedText()
		#else:
		addText()

func addText():
	var ab:AlphaCharacter = AlphaCharacter.new()
	doSplitWords()
	
	var xPos:float = 0
	for character in splitWords:
		if character == " " || character == "-":
			lastWasSpace = true
		if ab.alphabet.find(character.to_lower()) != -1:
			if lastSprite != null:
				xPos = lastSprite.position.x + lastSprite.sprite_frames.get_frame_texture(lastSprite.animation,0).get_width()
			
			if lastWasSpace:
				xPos += 45
				lastWasSpace = false
			
			var letter:AlphaCharacter = AlphaCharacter.new()
			letter.new(xPos,0)
			
			if isBold:
				letter.createBold(character)
			else:
				letter.createLetter(character)
			
			letter.centered = false
			letter.position.x = xPos
			add_child(letter)
			
			lastSprite = letter
	if optionItem:
		cb = AnimatedSprite2D.new()
		cb.sprite_frames = load("res://assets/images/checkboxThingie.xml")
		cb.play("Check Box unselected")
		cb.position.x = xPos + cb.sprite_frames.get_frame_texture("Check Box unselected",0).get_width() + 40
		cb.position.y = 30
		add_child(cb)
	if iconItem:
		icon = Sprite2D.new()
		icon.position.x = xPos + 75 + 75
		icon.position.y = 55
		add_child(icon)

func doSplitWords():
	var sw = _finalText.split("")
	splitWords.assign(sw)
	#print(sw)

func _physics_process(delta: float):
	if isMenuItem:
		var scaledY = remap(targetY,0,1,0,1.3)
		
		position.y = lerp(position.y, (scaledY * 120)+(720*0.48),0.16)
		position.x = lerp(position.x, (targetY * 20) + 90, 0.16)
	
	if optionItem:
		if !cbChecked:
			if cb.frame != 0:
				cb.play_backwards("Check Box selecting animation")
			if cb.frame == 0 && cb.animation != "Check Box unselected":
				cb.play("Check Box unselected")
		else:
			if cb.frame != 10 && cb.animation != "Check Box Selected Static":
				cb.play("Check Box selecting animation")
			if cb.frame == 10:
				cb.play("Check Box Selected Static")
		match cb.animation:
			"Check Box unselected":
				cb.offset = Vector2(0,0)
			"Check Box Selected Static":
				cb.offset = Vector2(6,-10)
			"Check Box selecting animation":
				cb.offset = Vector2(-6,-39)
