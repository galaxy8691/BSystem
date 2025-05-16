extends BAction

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	var is_playing_finished = blackboard.get("idle_animation_finished")
	if is_playing_finished == BType.ThreeStateBool.NOTSET:
		actor.play_idle()
		blackboard["idle_animation_finished"] = BType.ThreeStateBool.FALSE
		return BType.ActionType.RUNNING
	elif is_playing_finished == BType.ThreeStateBool.FALSE:
		return BType.ActionType.RUNNING
	else:
		blackboard["idle_animation_finished"] = BType.ThreeStateBool.NOTSET
		return BType.ActionType.SUCCESS
