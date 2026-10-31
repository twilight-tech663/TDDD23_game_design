class_name Player
extends CharacterBody2D

const SPEED := 80.0
const SURFACE_SPEED := 80.0
const DETACH_LOCK_TIME := 0.5
const GREEN_SLIME_GROWTH := 1.2
const DAMAGE_SHRINK := 0.2
const MIN_SIZE_MULTIPLIER := 0.2
const START_HEARTS := 2
const MAX_HEARTS := 3
const DEAD_STATE := 3
const RED_SLIME_SCENE := preload("res://scenes/slimes/red_slime/red_slime.tscn")
const WHITE_SLIME_SCENE := preload("res://scenes/slimes/white_slime/white_slime.tscn")

signal size_changed(size_multiplier: float)
signal death

var is_adhere := false
var surface_normal := Vector2.UP
var current_surface_collider: Node = null
var adhesion_lock_time := 0.0
var size_multiplier := 1.0
var hearts := START_HEARTS
@onready var health_hud: HealthHUD = $HealthHUD
var is_dead := false
var current_slime_type := slime_type.GREEN
var green_frames: SpriteFrames
var red_frames: SpriteFrames
var white_frames: SpriteFrames

enum slime_type{
	GREEN,
	RED,
	WHITE
}

func _ready() -> void:
	up_direction = Vector2.UP
	green_frames = $AnimatedSprite2D.sprite_frames
	var red_slime := RED_SLIME_SCENE.instantiate()
	red_frames = red_slime.get_node("AnimatedSprite2D").sprite_frames
	red_slime.free()
	var white_slime := WHITE_SLIME_SCENE.instantiate()
	white_frames = white_slime.get_node("AnimatedSprite2D").sprite_frames
	white_slime.free()

	var raycasts: Array[RayCast2D] = get_adhesion_raycasts()

	for raycast in raycasts:
		raycast.add_exception(self)
		
	$EatArea2D.body_entered.connect(_on_eat_area_body_entered)
	health_hud.set_slime_type(current_slime_type)
	health_hud.set_hearts(hearts)

func change_slime_type(new_type: int) -> void:
	current_slime_type = new_type
	health_hud.set_slime_type(new_type)
	match new_type:
		slime_type.RED:
			$AnimatedSprite2D.sprite_frames = red_frames
		slime_type.WHITE:
			$AnimatedSprite2D.sprite_frames = white_frames
		_:
			$AnimatedSprite2D.sprite_frames = green_frames
	$AnimatedSprite2D.play()
	if current_surface_collider != null and !_can_pass_surface(current_surface_collider):
		$FSM.change_state(DEAD_STATE)

func _on_eat_area_body_entered(body: Node2D) -> void:
	if body.has_method("is_green_slime") and body.is_green_slime():
		if current_slime_type != slime_type.GREEN:
			change_slime_type(slime_type.GREEN)
		else:
			grow_from_green_slime()
		body.consume()
		return

	if body.has_method("is_red_slime") and body.is_red_slime():
		change_slime_type(slime_type.RED)
		body.consume()
		return

	if body.has_method("is_white_slime") and body.is_white_slime():
		change_slime_type(slime_type.WHITE)
		body.consume()
		return

	if body is Coblin:
		if current_slime_type == slime_type.RED:
			body.take_damage(1)
		elif current_slime_type == slime_type.WHITE:
			body.freeze()
		return

func _realign_after_scale(previous_surface_offset: float) -> void:
	if !is_adhere:
		return

	var current_surface_offset := _surface_offset(surface_normal)
	global_position += surface_normal * (current_surface_offset - previous_surface_offset)

func grow_from_green_slime() -> void:
	if hearts >= MAX_HEARTS:
		return
	var previous_surface_offset := _surface_offset(surface_normal) if is_adhere else 0.0
	hearts += 1
	size_multiplier *= GREEN_SLIME_GROWTH
	scale = Vector2.ONE * size_multiplier
	_realign_after_scale(previous_surface_offset)
	health_hud.set_hearts(hearts)
	size_changed.emit(size_multiplier)

func take_damage(_amount: int = 1) -> void:
	if is_dead:
		return

	var previous_surface_offset := _surface_offset(surface_normal) if is_adhere else 0.0
	hearts = max(hearts - 1, 0)
	size_multiplier = max(size_multiplier - DAMAGE_SHRINK, MIN_SIZE_MULTIPLIER)
	scale = Vector2.ONE * size_multiplier
	_realign_after_scale(previous_surface_offset)
	health_hud.set_hearts(hearts)
	size_changed.emit(size_multiplier)
	if hearts <= 0:
		$FSM.change_state(DEAD_STATE)


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
			var collision_normal := _snap_to_axis(collision.get_normal())
			var collider := collision.get_collider() as Node
			if !_can_adhere_to(collider):
				continue
			if is_adhere and collider == current_surface_collider and collision_normal.dot(surface_normal) > 0.9:
				continue
			attach_to_surface(collision_normal, collision.get_position(), collider)
			return true
	return false

func _snap_to_axis(normal: Vector2) -> Vector2:
	if abs(normal.x) > abs(normal.y):
		return Vector2(signf(normal.x), 0.0)
	return Vector2(0.0, signf(normal.y))

func _can_adhere_to(collider: Node) -> bool:
	return (
		collider != null
		and not collider is Coblin
		and not collider.has_method("is_green_slime")
		and not collider.has_method("is_red_slime")
		and not collider.has_method("is_white_slime")
		and not collider.has_method("is_door")
	)

func _can_pass_surface(collider: Node) -> bool:
	if collider == null:
		return true
	if collider.has_method("is_fire_surface"):
		return current_slime_type == slime_type.RED
	if collider.has_method("is_ice_surface"):
		return current_slime_type == slime_type.WHITE
	return true

func _surface_offset(normal: Vector2) -> float:
	var shape := $CollisionShape2D.shape as Shape2D
	if shape == null:
		return 8.0
	var rect := shape.get_rect()
	var scaled_rect_size := rect.size * global_scale.abs()
	return scaled_rect_size.x * 0.5 if abs(normal.x) > abs(normal.y) else scaled_rect_size.y * 0.5

func attach_to_surface(
	normal: Vector2,
	contact_position: Vector2 = Vector2.INF,
	collider: Node = null
) -> void:
	if !_can_adhere_to(collider):
		return
	if !_can_pass_surface(collider):
		$FSM.change_state(DEAD_STATE)
		return

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

func update_adhesion_lock(delta: float) -> void:
	adhesion_lock_time = max(adhesion_lock_time - delta, 0.0) 

func move_on_surface(direction: float) -> void:
	var tangent := Vector2(-surface_normal.y, surface_normal.x)
	velocity = tangent * direction * SURFACE_SPEED
	move_and_slide()
	if !find_adhesion_surface():
		if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
			detach_from_surface()

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


