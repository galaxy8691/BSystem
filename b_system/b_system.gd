class_name BSystem extends BNode

@export var actor: Node
@export var blackboard: Dictionary = {}
@export var current_state: String = &"State_"


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
	blackboard[&"current_state"] = current_state
