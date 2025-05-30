class_name BComposite extends BNode




func _find_last_running_child(children: Array) -> int:
	var marker: int = 0
	for child_index in children.size():
		if children[child_index] is BNode and children[child_index].last_action_type == BType.ActionType.RUNNING:
			marker = child_index
	return marker

func _run_child_from_index(start_index: int, children: Array, stop_conditions: Array[BType.ActionType], actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	for child_index in children.size():
		if child_index >= start_index:
			var child: BNode = children[child_index]
			child._run(actor, blackboard, fn_change_state)
			if stop_conditions.has(child.last_action_type):
				return child.last_action_type
	return BType.ActionType.SUCCESS

func _sequence_tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	if last_action_type == BType.ActionType.NOTSET:
		return _run_child_from_index(0, get_children(), [BType.ActionType.FAILURE, BType.ActionType.RUNNING], actor, blackboard, fn_change_state)
		
	elif last_action_type == BType.ActionType.RUNNING:
		var marker: int = _find_last_running_child(get_children())
		last_action_type = get_children()[marker]._run(actor, blackboard, fn_change_state)
		if last_action_type == BType.ActionType.FAILURE or last_action_type == BType.ActionType.RUNNING:
			return last_action_type
		marker += 1
		if marker == get_children().size():
			last_action_type = BType.ActionType.SUCCESS
		else: 
			last_action_type = _run_child_from_index(marker, get_children(), [BType.ActionType.FAILURE, BType.ActionType.RUNNING], actor, blackboard, fn_change_state)
	return last_action_type

	
func _selector_tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	if last_action_type == BType.ActionType.NOTSET:
		last_action_type = _run_child_from_index(0, get_children(), [BType.ActionType.SUCCESS, BType.ActionType.RUNNING], actor, blackboard, fn_change_state)
	elif last_action_type == BType.ActionType.RUNNING:
		var marker: int = _find_last_running_child(get_children())
		last_action_type = get_children()[marker]._run(actor, blackboard, fn_change_state)
		if last_action_type == BType.ActionType.SUCCESS or last_action_type == BType.ActionType.RUNNING:
			return last_action_type
		marker += 1
		if marker == get_children().size():
			last_action_type = BType.ActionType.SUCCESS
		else: 
			last_action_type = _run_child_from_index(marker, get_children(), [BType.ActionType.SUCCESS, BType.ActionType.RUNNING], actor, blackboard, fn_change_state)
	return last_action_type
