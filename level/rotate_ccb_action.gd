extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	actor.rotate_counterclockwise_180()
	return BType.ActionType.SUCCESS
