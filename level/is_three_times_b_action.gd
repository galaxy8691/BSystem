extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	if actor.rotate_times == 200:
		return BType.ActionType.SUCCESS
	else:
		return BType.ActionType.FAILURE
