extends Node

enum Factions {fcRazemki, fcLibki, fcNaziole, fcKlechy, fcPlayer}

signal  score_change

var score: int = 0:
	#get:
	#return score
	set(value):
		score = value
		score_change.emit()

var player_pos: Vector2

var GameIsLoaded: bool = false
var PlayerInSafeZone: bool = false
var IsStartScreen: bool = false
var CurrentPopup: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
