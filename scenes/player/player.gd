class_name Player
extends CharacterBody2D

const SPEED := 100.0
const SURFACE_SPEED := 100.0
const DETACH_LOCK_TIME := 0.5

var is_adhere := false
var surface_normal := Vector2.UP
var current_surface_collider: CollisionObject2D = null
var adhesion_lock_time := 0.0

func _ready() -> void:
	up_direction = Vector2.UP
	var raycasts: Array[RayCast2D] = get_adhesion_raycasts()

	for raycast in raycasts:
		raycast.add_exception(self)

func _physics_process(delta: float) -> void:
	update_adhesion_lock(delta)

	if !is_adhere:
		find_adhesion_surface()

func get_adhesion_raycasts() -> Array[RayCast2D]:
	return [$AdhesionUp, $AdhesionDown, $AdhesionLeft, $AdhesionRight]

func find_adhesion_surface() -> bool:
	if adhesion_lock_time > 0:
		return false
	
	var raycasts: Array[RayCast2D] = get_adhesion_raycasts()
	for raycast in raycasts:
		raycast.force_raycast_update()
		#print("-----------------")
		#print(raycast.name, " colliding = ", raycast.is_colliding())
		#print("count: ", get_slide_collision_count())
		#print("-----------------")
		if !raycast.is_colliding():
			continue
		for collision_index in get_slide_collision_count():
			var collision := get_slide_collision(collision_index)
			var collision_normal := collision.get_normal().normalized()
			var collider := collision.get_collider() as CollisionObject2D
			if is_adhere and collider == current_surface_collider and collision_normal.dot(surface_normal) > 0.9:
				continue
			attach_to_surface(collision_normal, collision.get_position(), collider)
			return true
	return false

func attach_to_surface(
	normal: Vector2,
	contact_position: Vector2 = Vector2.INF,
	collider: CollisionObject2D = null
) -> void:
	var normalized_normal := normal.normalized()
	var is_same_surface := is_adhere and collider == current_surface_collider and normalized_normal.dot(surface_normal) > 0.9
	
	# update adhesion state
	is_adhere = true
	surface_normal = normalized_normal
	current_surface_collider = collider
	up_direction = surface_normal

	if !is_same_surface:
		velocity = Vector2.ZERO
		if contact_position != Vector2.INF:
			global_position = contact_position + surface_normal * _surface_offset(surface_normal)
	$AnimatedSprite2D.rotation = surface_normal.angle() + PI / 2.0

func _surface_offset(normal: Vector2) -> float:
	var shape := $CollisionShape2D.shape as Shape2D
	if shape == null:
		return 8.0
	var rect := shape.get_rect()
	return rect.size.x * 0.5 if abs(normal.x) > abs(normal.y) else rect.size.y * 0.5

func detach_from_surface() -> void:
	if !is_adhere:
		return

	is_adhere = false
	current_surface_collider = null
	velocity = surface_normal * 120.0
	adhesion_lock_time = DETACH_LOCK_TIME
	surface_normal = Vector2.UP
	up_direction = Vector2.UP
	$AnimatedSprite2D.rotation = 0.0

func update_adhesion_lock(delta: float) -> void:
	adhesion_lock_time = max(adhesion_lock_time - delta, 0.0) 

func move_on_surface(direction: float) -> void:
	var tangent := Vector2(-surface_normal.y, surface_normal.x)
	velocity = tangent * direction * SURFACE_SPEED
	move_and_slide()
	if !find_adhesion_surface():
		if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
			detach_from_surface()
