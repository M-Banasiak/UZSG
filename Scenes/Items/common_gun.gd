extends StaticBody2D

@export var damage: int
@export var penetration: int

var parent_node: Node
var item_owner: Node
var gun_direction: Vector2
var hit_data: Dictionary
var mouse_hit_data: Array[Dictionary]
var is_player_gun: bool
var curr_mouse_pos: Vector2

@onready var shoot_raycast: RayCast2D = $ShootRayCast

#signal  gun_fired(pos: Vector2, direction: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()
	item_owner = parent_node.get_parent()
	shoot_raycast.add_exception(item_owner)
	hit_data[DictConsts.HitData.htPower] = damage
	hit_data[DictConsts.HitData.htPenetration] = penetration
	hit_data[DictConsts.HitData.htAttacker] = item_owner
	if "get_faction" in item_owner:
		hit_data[DictConsts.HitData.htFaction] = item_owner.get_faction()
	if "is_player" in item_owner:
		is_player_gun = item_owner.is_player()
	else:
		is_player_gun = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_player_gun == true:
		look_at(get_global_mouse_position())
		gun_direction = Vector2.RIGHT.rotated(rotation)
	
func _physics_process(_delta):
	if is_player_gun == true:
		var space_state = get_world_2d().direct_space_state
		var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		curr_mouse_pos = get_global_mouse_position()
		query.position = curr_mouse_pos
		#te maski dać jako stałe słownikowe żeby się nie myliło
		query.collision_mask = 0b1001 #tylko collision layer 1. 0b1001 dla 1 i 4 https://docs.godotengine.org/en/4.6/tutorials/physics/physics_introduction.html#collision-layers-and-masks
		mouse_hit_data = space_state.intersect_point(query)
		

func accumulate_hits() -> Array[Object]:
	var hit_objects: Array[Object]
	var hit_object: Object
	var hits = penetration
	var armor: int
	
	shoot_raycast.force_raycast_update()
	while(hits > 0) :
		hit_object = shoot_raycast.get_collider()
		if hit_object != null:
			hit_objects.append(hit_object)
			shoot_raycast.add_exception(hit_object)
			shoot_raycast.force_raycast_update()
			if "get_wall_armor" in hit_object:   
				armor = hit_object.get_wall_armor()  #kończymy pętlę jak przebijemy więcej muru niż pen...
			else:
				armor = 0
			hits = hits - armor 
		else:
			break #... albo jak nie ma już żadnych kolidujących obiektów
	
	shoot_raycast.clear_exceptions()
	shoot_raycast.add_exception(item_owner)
	return hit_objects

#wywoływane przez player
#przekazuje globalne współrzędne końca lufy i kierunek
#player emituje sygnał, który na levelu powoduje utworzenie kuli.
#obecnie sygnał zostawiamy dla efektów wizualnych na levelu.
#natomiast trafienie przekazujemy bezpośrednio do zraycastowanego obiektu
func fire_single() -> Dictionary: #Array[Vector2]:  
	var hit_objects: Array[Object] = accumulate_hits()   #wszystkie obiekty przecięte przez raycast
	var hit_target: Object                               #trafiony obiekt
	var curr_pen: int = penetration
	
	#Cyścimy hit_data bo to zmienna globalnie bo zawiera info o właścicielu broni, penetracji itd.
	hit_data.erase(DictConsts.HitData.htTarget)
	hit_data.erase(DictConsts.HitData.htIsGlancing)
	hit_data.erase(DictConsts.HitData.htStartPos)
	hit_data.erase(DictConsts.HitData.htDirection)
	#Pen do obsłużenia. Będzie przekazywany oryginalny pen
	hit_data.erase(DictConsts.HitData.htPenetration)
	
	#jeśli myszka na pierwszym NPC przeciętym przez raycast to strzał celowany
	#szukamy pierwszego npc oraz ustalamy penetrację
	for hit_object: Object in hit_objects:
		if "get_type" in hit_object:
				if hit_object.get_type() == DictConsts.ObjectType.otNpc:
					hit_target = hit_object
					break
				else:
					if "get_wall_armor" in hit_object:
						curr_pen = curr_pen - hit_object.get_wall_armor() 
						
	#jeśli nie trafił w NPC, to pierwszy trafiony obiekt dla potrzeb animacji
	if hit_objects.size() > 0 and not hit_target:
		hit_target = hit_objects[0]
	
	#sprawdzamy, czy myszka była na trafionym obiekcie
	hit_data[DictConsts.HitData.htIsGlancing] = true
	if hit_target:
		for mouse_hit: Dictionary in mouse_hit_data:
			#print(mouse_hit["collider"])
			if mouse_hit["collider"] == hit_target:
				hit_data[DictConsts.HitData.htIsGlancing] = false		#tego nie wiemy, bo symulujemy kule w świeceie gry i może trafić w co innego
				hit_data[DictConsts.HitData.htTarget] = mouse_hit["collider"]
		
		hit_data[DictConsts.HitData.htPenetration] = curr_pen
		
		#var strHit: String = "Trafił w: " + str(hit_target.name)
		#if hit_data[DictConsts.HitData.htIsGlancing] == false:
		#	strHit = strHit + " celnie."
		#else:
		#	strHit = strHit + " niecelnie."
		#strHit = strHit + " Penetracja: " + str(curr_pen)+"."
		#print(strHit)		
				
		#if "hit_alt" in hit_target:
		#	hit_target.hit_alt(hit_data)
	else:
		pass#print("W nic nie trafił")
	
	#Zwracamy słownik z informacją o strzale (hit_data)
	#hit_data zostanie przekazane do kuli
	#kula wywoła hit_alt na faktycznie trafionym obiekcie
	#Jeśli trafiony obiekt to hit_data[DictConsts.HitData.htTarget], wtedy mamy strzał celowany
	#if hit_target:
		#hit_data[DictConsts.HitData.htTarget] = hit_target
	hit_data[DictConsts.HitData.htStartPos] = global_position
	hit_data[DictConsts.HitData.htDirection] = gun_direction
	return hit_data
	
	#gun_fired.emit($BulletOrigin.global_position, gun_direction)
	#oprócz tego tego create raycast, jak w coś trafi to w zwracanych parametrach
	#przekazywać trafiony obiekt i odległość kursora myszki w momencie trafienia/wywoływać funkcję obiektu hit
