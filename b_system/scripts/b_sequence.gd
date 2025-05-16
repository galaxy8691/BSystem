class_name BSequence extends BComposite


func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	return _sequence_tick(actor, blackboard, fn_change_state)

