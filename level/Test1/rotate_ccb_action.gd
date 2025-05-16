extends BAction

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	actor.rotate_counterclockwise_180()
	return BType.ActionType.SUCCESS
