extends BAction

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	var is_playing_finished = blackboard.get("idle_animation_finished")
	if is_playing_finished == null:
		return BType.ActionType.SUCCESS
	elif is_playing_finished == false:
		return BType.ActionType.FAILURE
	else:
		return BType.ActionType.SUCCESS
		
