extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	var is_playing_finished = get_blackboard("idle_animation_finished")
	if is_playing_finished == null:
		return BType.ActionType.SUCCESS
	elif is_playing_finished == false:
		return BType.ActionType.FAILURE
	else:
		return BType.ActionType.SUCCESS
		
