class_name BComposite extends BNode

@export var state: String = &"State_"


func _find_last_running_child(children: Array) -> int:
	var marker: int = 0
	for child_index in children.size():
		if children[child_index] is BNode and children[child_index].last_action_type == BType.ActionType.RUNNING:
			marker = child_index
	return marker

func _run_child_from_index(start_index: int, children: Array, stop_conditions: Array[BType.ActionType], actor: Node, blackboard: Dictionary) -> BType.ActionType:
	for child_index in children.size():
		if child_index >= start_index:
			var child: BNode = children[child_index]
			child.tick(actor, blackboard)
			if stop_conditions.has(child.last_action_type):
				return child.last_action_type
	return BType.ActionType.NOTSET
