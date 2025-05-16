extends BAction

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	fn_change_state.call("CounterClockwise")
	return BType.ActionType.SUCCESS
