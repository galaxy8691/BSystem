extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	set_current_state("Clockwise")
	return BType.ActionType.SUCCESS
