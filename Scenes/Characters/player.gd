extends CharacterBody2D

enum eDirection {ldLeft, ldRight}
enum eFireMode {fmSemi, fmAuto}

@export var max_speed: int = 100
@export var fire_rate: float = 0.25  #odstęp między strzałami w trybie auto (s)
var speed: int = max_speed
var look_direction
var fire_mode: eFireMode = eFireMode.fmSemi
var fire_cooldown: float = 0.0

signal  gun_fired(bullet_data: Dictionary) #Array[Vector2])  #0 - position, 1 - direction (zmienić na Dictionary albo inner class)

func _ready() -> void:
	look_direction = eDirection.ldRight
	update_fire_mode_name()

func _process(delta: float) -> void:
	
	#input
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	CurrentGameState.player_pos = global_position
	
	var mouse_pos = get_global_mouse_position()
	if global_position.x > mouse_pos.x and look_direction == eDirection.ldRight:
		scale.x = - scale.x #- def_scale
		look_direction = eDirection.ldLeft
		#$Weapons/PrimaryWeapon.z_index = -1
	elif global_position.x <= mouse_pos.x and look_direction == eDirection.ldLeft:
		scale.x = - scale.x 
		look_direction = eDirection.ldRight
		#$Weapons/PrimaryWeapon.z_index = 0
	
	if Input.is_action_just_pressed("switch_fire_mode"):
		switch_fire_mode()

	#action_pressed/just_pressed uzależniamy od tego czy auto, czy single
	fire_cooldown = max(fire_cooldown - delta, 0.0)
	match fire_mode:
		eFireMode.fmSemi:
			if Input.is_action_just_pressed("shoot_primary"):
				fire()
		eFireMode.fmAuto:
			if Input.is_action_pressed("shoot_primary") and fire_cooldown <= 0.0:
				fire()
				fire_cooldown = fire_rate

func fire() -> void:
	var bullet_data: Dictionary #Array[Vector2]
	if "fire_single" in $Weapons/AdiGun:
		bullet_data = $Weapons/AdiGun.fire_single()
	else:
		return
	#teraz jest tak bo zmiana kierunku patrzenia odbywa się przez zmianę scale
	#jak wprowadzimy animacje to wyemitowanie sygnału do wygenerowania kuli przeniesiemy na common_gun
	#choć pewnie trza będzie dynamicznie podłączyć, bo z poziomu level, signal z gun jest niewidoczny
	if look_direction == eDirection.ldLeft:
		var dir: Vector2 = bullet_data[DictConsts.HitData.htDirection]
		dir.x *= -1
		bullet_data[DictConsts.HitData.htDirection] = dir
	gun_fired.emit(bullet_data)

func switch_fire_mode() -> void:
	if fire_mode == eFireMode.fmSemi:
		fire_mode = eFireMode.fmAuto
	else:
		fire_mode = eFireMode.fmSemi
	fire_cooldown = 0.0
	update_fire_mode_name()

#klucz tłumaczenia nazwy trybu wyświetlanej w LevelUI
func update_fire_mode_name() -> void:
	match fire_mode:
		eFireMode.fmSemi:
			CurrentGameState.fire_mode_name = "FIRE_MODE_SEMI"
		eFireMode.fmAuto:
			CurrentGameState.fire_mode_name = "FIRE_MODE_AUTO"

func get_faction() -> DictConsts.Factions:
	return DictConsts.Factions.fcPlayer
	
func is_player() -> bool:
	return true
