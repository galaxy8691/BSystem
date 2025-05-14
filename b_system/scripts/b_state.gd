class_name BState extends BNode

var state: String = &"State_"


func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	if last_action_type == BType.ActionType.NOTSET:
		for child in get_children():
			if child is BNode:
				last_action_type = child.tick(actor, blackboard)
				if last_action_type == BType.ActionType.FAILURE or last_action_type == BType.ActionType.RUNNING:
					break
	elif last_action_type == BType.ActionType.RUNNING:
		for child in get_children():
			if child is BNode and child:
				last_action_type = child.tick(actor, blackboard)
				if last_action_type == BType.ActionType.FAILURE:
					break
	return last_action_type
