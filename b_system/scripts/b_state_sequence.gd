class_name BStateSequence extends BStateComposite

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	return _sequence_tick(actor, blackboard)

