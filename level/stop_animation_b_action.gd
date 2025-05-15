extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	actor.stop_animation()
	return BType.ActionType.SUCCESS
