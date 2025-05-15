extends BAction

func tick(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	var is_playing_finished = get_blackboard("idle_animation_finished")
	if is_playing_finished == BType.ThreeStateBool.NOTSET:
		actor.play_idle()
		set_blackboard("idle_animation_finished", BType.ThreeStateBool.FALSE)
		return BType.ActionType.RUNNING
	elif is_playing_finished == BType.ThreeStateBool.FALSE:
		return BType.ActionType.RUNNING
	else:
		set_blackboard("idle_animation_finished", BType.ThreeStateBool.NOTSET)
		return BType.ActionType.SUCCESS
