class_name BStateSelector extends BStateComposite


func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	return _selector_tick(actor, blackboard)
