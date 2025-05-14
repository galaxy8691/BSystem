extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	actor.rotate_clockwise_180()
	return BType.ActionType.SUCCESS
