extends CharacterBody2D

enum eDirection {ldLeft, ldRight}

@export var max_speed: int = 100
var speed: int = max_speed
var look_direction

signal  gun_fired(bullet_data: Dictionary) #Array[Vector2])  #0 - position, 1 - direction (zmienić na Dictionary albo inner class)

func _ready() -> void:
	look_direction = eDirection.ldRight

func _process(_delta: float) -> void:
	
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
	
	#action_pressed/just_pressed uzależniamy od tego czy auto, czy single	
	if Input.is_action_just_pressed("shoot_primary"):
		var bullet_data: Dictionary #Array[Vector2]
		if "fire_single" in $Weapons/AdiGun:
			bullet_data = $Weapons/AdiGun.fire_single()
		#teraz jest tak bo zmiana kierunku patrzenia odbywa się przez zmianę scale
		#jak wprowadzimy animacje to wyemitowanie sygnału do wygenerowania kuli przeniesiemy na common_gun
		#choć pewnie trza będzie dynamicznie podłączyć, bo z poziomu level, signal z gun jest niewidoczny		
		if look_direction == eDirection.ldLeft:
			bullet_data[1].x *= -1
		gun_fired.emit(bullet_data)

func get_faction() -> DictConsts.Factions:
	return DictConsts.Factions.fcPlayer
	
func is_player() -> bool:
	return true
