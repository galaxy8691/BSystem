class_name ChangeStateBAction extends BAction

@export var state: String

func tick(_actor: Node, _blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	print("change_state_b_action:", state)
	fn_change_state.call(state)
	return BType.ActionType.SUCCESS
