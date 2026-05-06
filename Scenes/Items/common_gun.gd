extends StaticBody2D

@export var damage: int
var parent_node: Node
var gun_direction: Vector2

#signal  gun_fired(pos: Vector2, direction: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent_node = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	gun_direction = Vector2.RIGHT.rotated(rotation)
	
	#if Input.is_action_pressed("shoot_primary"):
	#	#przenieść na player. Na playerze znajdujemy active weapon, jej rotacje i strzelamy
	#	gun_fired.emit($BulletOrigin.global_position, gun_direction)
		
#przekazuje globalne współrzędne końca lufy i kierunek
func fire_single() -> Array[Vector2]:  
	#to zmienimy z tablicy na directory z roznymi parametrami typu typ kuli
	return [$BulletOrigin.global_position, gun_direction]
	#gun_fired.emit($BulletOrigin.global_position, gun_direction)
