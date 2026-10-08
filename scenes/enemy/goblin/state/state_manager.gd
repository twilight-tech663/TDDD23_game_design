class_name Coblin_State_Manager
extends Node

var states_array:Array = []
@onready var current: Coblin_Base_State = $Walk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	states_array = get_children()
	current.enter()
	
func _physics_process(delta: float) -> void:
	current.do(delta)
	
func change_state(id:int)->void:
	if current == states_array[id]:
		return
	current.exit()
	current = states_array[id]
	current.enter()
	
