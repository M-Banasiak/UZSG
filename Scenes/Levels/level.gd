extends Node2D

@export var Menu: MainMenu
@export var spawned_scenes: Array[Node2D]

var bullet_scene: PackedScene = preload("res://Scenes/Projectiles/bullet_rifle.tscn") #przenieść na common_gun
var razem_guy: PackedScene = preload("res://Scenes/Characters/razemek.tscn")
var lib_guy: PackedScene = preload("res://Scenes/Characters/libek.tscn")
var nazi_guy: PackedScene = preload("res://Scenes/Characters/naziol.tscn")
var bg_sound: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	CurrentGameState.IsStartScreen = false
	CurrentGameState.GameIsLoaded = true
	Menu.HideMenu()
	$Spawners/RazemSpawner.connect("character_spawned", _on_create_character)
	$Spawners/EnemySpawner.character_spawned.connect(_on_create_character)
	$Spawners/NaziolSpawner.character_spawned.connect(_on_create_character)
	bg_sound = Music.find_child("MusicMiedzynar")
	bg_sound.stop()
	bg_sound = Music.find_child("MusicAtom")
	bg_sound.play()
	#var NPP: Sprite2D = $ActiveObjects/NuclearPowerPlant/TestImg
	#var npp_origin: Vector2 = NPP.global_position
	#var right_center:Vector2 = npp_origin + Vector2(NPP.texture.get_width(), 0)
	#var top_center:Vector2 = npp_origin + Vector2(NPP.texture.get_height(), 0)
	#print(npp_origin)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#if Input.is_action_pressed("close_current_menu"):
	#	Menu.visible = not Menu.visible
		
func _on_player_gun_fired(bullet_data: Dictionary ) -> void:  #Array[Vector2]
	create_bullet(bullet_data)
	
func create_bullet(bullet_data: Dictionary) -> void:  #bullet_data zamienić na dictionary albo inner class
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.position = bullet_data[DictConsts.HitData.htStartPos]  #bullet_data[0]
	bullet.rotation_degrees = rad_to_deg(bullet_data[DictConsts.HitData.htDirection].angle()) + 0   #zamiast robić to przeliczenie mogę od razu przekazywać kąt 
	bullet.direction = bullet_data[DictConsts.HitData.htDirection]
	bullet.my_shooter = $Player
	bullet.hit_info = bullet_data
	$Projectiles.add_child(bullet)
	
func _on_create_character(pos: Vector2, faction: DictConsts.Factions) -> void:
	match faction:
		CurrentGameState.Factions.fcRazemki:
			var new_npc: Razemek = razem_guy.instantiate()
			new_npc.position = pos
			new_npc.curr_target = $ActiveObjects/NuclearPowerPlant
			$RazemGuys.add_child(new_npc)
		CurrentGameState.Factions.fcLibki:
			var new_npc: Libek = lib_guy.instantiate()
			new_npc.position = pos
			$Enemies.add_child(new_npc)
		CurrentGameState.Factions.fcNaziole:
			var new_npc: Naziol = nazi_guy.instantiate()
			new_npc.position = pos
			$Enemies.add_child(new_npc)
			new_npc.character_spawned.connect(_on_create_character)
