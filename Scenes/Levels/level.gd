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
	#wczytanie gry (Kontynuuj/Wczytaj) przeładowuje level i nakłada stan z pliku
	if not SaveEngine.load_path.is_empty():
		var path: String = SaveEngine.load_path
		SaveEngine.load_path = ""
		apply_save_data(SaveEngine.LoadGame(path))
	else:
		CurrentGameState.score = 0 #nowa gra
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
	
#zwraca utworzoną kulę - używane przy wczytywaniu gry
func create_bullet(bullet_data: Dictionary) -> Area2D:  #bullet_data zamienić na dictionary albo inner class
	var bullet: Area2D = bullet_scene.instantiate()
	bullet.position = bullet_data[DictConsts.HitData.htStartPos]  #bullet_data[0]
	bullet.rotation_degrees = rad_to_deg(bullet_data[DictConsts.HitData.htDirection].angle()) + 0   #zamiast robić to przeliczenie mogę od razu przekazywać kąt 
	bullet.direction = bullet_data[DictConsts.HitData.htDirection]
	#strzelec z danych broni (gracz albo NPC); null, jeśli już nie istnieje
	var shooter = bullet_data.get(DictConsts.HitData.htAttacker)
	bullet.my_shooter = shooter if is_instance_valid(shooter) else null
	bullet.hit_info = bullet_data.duplicate()
	$Projectiles.add_child(bullet)
	return bullet
	
#zwraca utworzonego NPC (null dla nieobsługiwanej frakcji) - używane przy wczytywaniu gry
func _on_create_character(pos: Vector2, faction: DictConsts.Factions) -> NPCBasicBehavior:
	match faction:
		DictConsts.Factions.fcRazemki:
			var new_npc: Razemek = razem_guy.instantiate()
			new_npc.position = pos
			new_npc.curr_target = $ActiveObjects/NuclearPowerPlant
			$RazemGuys.add_child(new_npc)
			return new_npc
		DictConsts.Factions.fcLibki:
			var new_npc: Libek = lib_guy.instantiate()
			new_npc.position = pos
			$Enemies.add_child(new_npc)
			return new_npc
		DictConsts.Factions.fcNaziole:
			var new_npc: Naziol = nazi_guy.instantiate()
			new_npc.position = pos
			$Enemies.add_child(new_npc)
			new_npc.character_spawned.connect(_on_create_character)
			new_npc.gun_fired.connect(create_bullet)
			return new_npc
	return null

#rodzaj NPC w zapisie wg klasy, nie get_faction() - Razemek dziedziczy faction z basic_npc.tscn
const NPC_SAVE_KINDS: Dictionary = {
	"razemek": DictConsts.Factions.fcRazemki,
	"libek": DictConsts.Factions.fcLibki,
	"naziol": DictConsts.Factions.fcNaziole,
}

func npc_save_kind(npc: Node) -> String:
	if npc is Razemek:
		return "razemek"
	if npc is Libek:
		return "libek"
	if npc is Naziol:
		return "naziol"
	return ""

#stan gry do zapisu w JSON (SaveEngine.SaveGame)
func get_save_data() -> Dictionary:
	var npcs: Array = []
	var npc_ids: Dictionary = {} #NPC -> indeks w npcs, do zapisu strzelca kuli
	for container: Node in [$RazemGuys, $Enemies]:
		for npc: Node in container.get_children():
			if npc.is_queued_for_deletion():
				continue
			var kind: String = npc_save_kind(npc)
			if kind.is_empty():
				continue
			npc_ids[npc] = npcs.size()
			npcs.append({
				"kind": kind,
				"position": SaveEngine.vec_to_json(npc.global_position),
				"target_pos": SaveEngine.vec_to_json(npc.curr_target_pos),
				"patrol_speed": npc.patrol_speed,
				"attack_speed": npc.attack_speed,
			})

	#z hit_info zapisujemy tylko wartości; strzelec jako "player" / indeks w npcs / null (już nie żyje)
	var bullets: Array = []
	for bullet: Node in $Projectiles.get_children():
		if bullet.is_queued_for_deletion():
			continue
		var shooter = null
		if is_instance_valid(bullet.my_shooter):
			if bullet.my_shooter == $Player:
				shooter = "player"
			elif npc_ids.has(bullet.my_shooter):
				shooter = npc_ids[bullet.my_shooter]
		bullets.append({
			"shooter": shooter,
			"position": SaveEngine.vec_to_json(bullet.global_position),
			"traveled": bullet.traveled,
			"direction": SaveEngine.vec_to_json(bullet.direction),
			"power": bullet.hit_info.get(DictConsts.HitData.htPower, 0),
			"penetration": bullet.hit_info.get(DictConsts.HitData.htPenetration, 0),
			"faction": bullet.hit_info.get(DictConsts.HitData.htFaction, DictConsts.Factions.fcPlayer),
			"is_glancing": bullet.hit_info.get(DictConsts.HitData.htIsGlancing, true),
		})

	return {
		"score": CurrentGameState.score,
		"player": {
			"position": SaveEngine.vec_to_json($Player.global_position),
			"fire_mode": $Player.fire_mode,
		},
		"npcs": npcs,
		"bullets": bullets,
	}

#odtwarza stan z get_save_data(); NPC i kule ze sceny są zastępowane zapisanymi
func apply_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	CurrentGameState.score = int(data.get("score", 0))

	var player_data: Dictionary = data.get("player", {})
	if player_data.has("position"):
		$Player.global_position = SaveEngine.json_to_vec(player_data["position"])
	$Player.fire_mode = int(player_data.get("fire_mode", 0))
	$Player.update_fire_mode_name()

	#remove_child od razu, żeby stare obiekty nie wisiały do końca klatki
	for container: Node in [$RazemGuys, $Enemies, $Projectiles]:
		for child: Node in container.get_children():
			container.remove_child(child)
			child.queue_free()

	var npc_nodes: Array = [] #indeksy jak w zapisie, do odtworzenia strzelców kul
	for npc_data: Dictionary in data.get("npcs", []):
		if not NPC_SAVE_KINDS.has(npc_data.get("kind", "")):
			npc_nodes.append(null)
			continue
		var npc: NPCBasicBehavior = _on_create_character(SaveEngine.json_to_vec(npc_data["position"]), NPC_SAVE_KINDS[npc_data["kind"]])
		npc_nodes.append(npc)
		npc.patrol_speed = int(npc_data.get("patrol_speed", npc.patrol_speed))
		npc.attack_speed = int(npc_data.get("attack_speed", npc.attack_speed))
		if npc_data.has("target_pos"):
			npc.curr_target_pos = SaveEngine.json_to_vec(npc_data["target_pos"])

	for bullet_data: Dictionary in data.get("bullets", []):
		var faction: int = int(bullet_data.get("faction", DictConsts.Factions.fcPlayer))
		var shooter: Node = null
		if not bullet_data.has("shooter"):
			#zapis sprzed zapamiętywania strzelca
			shooter = $Player if faction == DictConsts.Factions.fcPlayer else null
		elif bullet_data["shooter"] is String and bullet_data["shooter"] == "player":
			shooter = $Player
		elif bullet_data["shooter"] is float:
			var idx: int = int(bullet_data["shooter"])
			if idx >= 0 and idx < npc_nodes.size():
				shooter = npc_nodes[idx]
		var bullet: Area2D = create_bullet({
			DictConsts.HitData.htAttacker: shooter,
			DictConsts.HitData.htStartPos: SaveEngine.json_to_vec(bullet_data["position"]),
			DictConsts.HitData.htDirection: SaveEngine.json_to_vec(bullet_data["direction"]),
			DictConsts.HitData.htPower: int(bullet_data.get("power", 0)),
			DictConsts.HitData.htPenetration: int(bullet_data.get("penetration", 0)),
			DictConsts.HitData.htFaction: faction,
			DictConsts.HitData.htIsGlancing: bool(bullet_data.get("is_glancing", true)),
		})
		bullet.traveled = float(bullet_data.get("traveled", 0.0)) #zasięg liczony dalej, nie od nowa
