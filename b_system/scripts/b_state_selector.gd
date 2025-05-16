class_name BStateSelector extends BStateComposite


func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	return _selector_tick(actor, blackboard, fn_change_state)
