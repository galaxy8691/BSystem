extends BAction
func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	print("tell_finished_b_action")
	return BType.ActionType.SUCCESS
