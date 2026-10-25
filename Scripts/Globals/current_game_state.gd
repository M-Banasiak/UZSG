extends Node

signal  score_change
signal  fire_mode_change

var score: int = 0:
	#get:
	#return score
	set(value):
		score = value
		score_change.emit()

var fire_mode_name: String = "":
	set(value):
		fire_mode_name = value
		fire_mode_change.emit()

var player_pos: Vector2

var GameIsLoaded: bool = false
var PlayerInSafeZone: bool = false
var IsStartScreen: bool = false
var CurrentPopup: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#gra startuje w wersji polskiej, przełączenie w menu (BtnLanguage)
	TranslationServer.set_locale("pl")
