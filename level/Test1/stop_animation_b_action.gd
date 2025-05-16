extends BAction

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	actor.stop_animation()
	return BType.ActionType.SUCCESS
