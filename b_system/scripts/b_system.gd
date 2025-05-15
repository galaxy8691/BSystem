class_name BSystem extends BNode

@export var actor: Node
@export var blackboard: Dictionary = {}
var current_state: String = &"State_"
@export var init_state: String = &"State_"

func _ready():
	var init_state_name = init_state.trim_prefix("State_")
	system_change_state(init_state_name)

func _physics_process(_delta: float) -> void:
	for child in get_children():
		if child is BComposite and child.state == current_state:
			last_action_type = child._run(actor, blackboard)
			if last_action_type == BType.ActionType.FAILURE or last_action_type == BType.ActionType.SUCCESS:
				clear()
				break

func system_change_state(state: String):
	var state_name = "State_" + state
	current_state = state_name
	for child in get_children():
		if child is BComposite and child.state == current_state:
			child._init_when_change_state(actor, blackboard)

func _set_system_blackboard(key: String, value: Variant):
	blackboard[key] = value

func _get_system_blackboard(key: String):
	return blackboard.get(key)
