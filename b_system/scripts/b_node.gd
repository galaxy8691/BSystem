class_name BNode extends Node
var last_action_type: BType.ActionType = BType.ActionType.NOTSET


func _run(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	last_action_type = tick(actor, blackboard, fn_change_state)
	return last_action_type

func tick(_actor: Node, _blackboard: Dictionary, _fn_change_state: Callable) -> BType.ActionType:
	return BType.ActionType.NOTSET

func clear():
	last_action_type = BType.ActionType.NOTSET
	for child in get_children():
		if child is BNode:
			child.clear()





