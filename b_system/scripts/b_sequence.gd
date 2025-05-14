class_name BSequence extends BComposite


func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	if last_action_type == BType.ActionType.NOTSET:
		var temp =_run_child_from_index(0, get_children(), [BType.ActionType.FAILURE, BType.ActionType.RUNNING], actor, blackboard)
		# if temp == BType.ActionType.FAILURE:
		# 	print("BSequence: ", temp)
		return temp
	elif last_action_type == BType.ActionType.RUNNING:
		var marker: int = _find_last_running_child(get_children())
		last_action_type = get_children()[marker]._run(actor, blackboard)
		if last_action_type == BType.ActionType.FAILURE or last_action_type == BType.ActionType.RUNNING:
			return last_action_type
		marker += 1
		if marker == get_children().size():
			last_action_type = BType.ActionType.SUCCESS
		else: 
			last_action_type = _run_child_from_index(marker, get_children(), [BType.ActionType.FAILURE, BType.ActionType.RUNNING], actor, blackboard)
	return last_action_type

