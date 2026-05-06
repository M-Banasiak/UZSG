extends Node2D 

@export var Menu: MainMenu
var bg_sound: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport: Window = get_tree().root
	print(viewport.size)
	#viewport.size = (Vector2(1920,1080))
	CurrentGameState.IsStartScreen = true;
	CurrentGameState.GameIsLoaded = false;
	Menu.ShowMenu()
	bg_sound = Music.find_child("MusicAtom")
	bg_sound.stop()
	bg_sound = Music.find_child("MusicMiedzynar")
	bg_sound.play()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
