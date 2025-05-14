class_name BNode extends Node
var last_action_type: BType.ActionType = BType.ActionType.NOTSET

func tick(_actor: Node, _blackboard: Dictionary) -> BType.ActionType:
	last_action_type = BType.ActionType.NOTSET
	return last_action_type

func clear():
	last_action_type = BType.ActionType.NOTSET
	for child in get_children():
		if child is BNode:
			child.clear()
