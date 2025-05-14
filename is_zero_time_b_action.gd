extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	if actor.rotate_times == 0:
		print(actor.rotate_times)
		return BType.ActionType.SUCCESS
	else:
		return BType.ActionType.FAILURE
