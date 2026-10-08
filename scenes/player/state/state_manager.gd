class_name State_Manager
extends Node

var states_array:Array = []
@onready var current : Base_State = $idle

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
	
