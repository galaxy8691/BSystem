class_name BSelector extends BComposite

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	return _selector_tick(actor, blackboard)


