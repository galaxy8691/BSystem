extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	set_current_state("CounterClockwise")
	return BType.ActionType.SUCCESS
