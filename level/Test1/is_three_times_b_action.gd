extends BAction

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	if actor.rotate_times == 200:
		return BType.ActionType.SUCCESS
	else:
		return BType.ActionType.FAILURE
