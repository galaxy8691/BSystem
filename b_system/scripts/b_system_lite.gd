class_name BSystemLite extends Node

var state_fns: Dictionary = {}
var init_when_change_state_fns: Dictionary = {}
var state_last_types: Dictionary = {}
var blackboard: Dictionary = {}

@export var actor: Node
@export var init_state: String

func _ready():
	_init_call()
	

func start_system():
	change_state(init_state)

func insert_state(state: String, fn: Callable, init_fn: Callable):
	state_fns[state] = fn
	init_when_change_state_fns[state] = init_fn

func insert_state_last_type(state: String, last_type: String):
	state_last_types[state] = last_type

func change_state(state: String):
	blackboard["current_state"] =  state
	var init_when_change_state_fn = init_when_change_state_fns.get(state)
	init_when_change_state_fn.call()

func _init_call():
	pass

func _physics_process(_delta: float) -> void:
	var current_state = blackboard.get("current_state")
	var state_fn = state_fns.get(current_state)
	state_fn.call()
