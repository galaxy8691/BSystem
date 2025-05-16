class_name BSelector extends BComposite

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	return _selector_tick(actor, blackboard, fn_change_state)


