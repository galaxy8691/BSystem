extends BAction
func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	print("tell_finished_b_action")
	return BType.ActionType.SUCCESS
