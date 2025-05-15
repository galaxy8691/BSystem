class_name ChangeStateBAction extends BAction

@export var state: String

func tick(_actor: Node, _blackboard: Dictionary) -> BType.ActionType:
	print("change_state_b_action:", state)
	set_current_state(state)
	return BType.ActionType.SUCCESS
