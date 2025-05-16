extends BAction

func tick(actor: Node, blackboard: Dictionary, fn_change_state: Callable) -> BType.ActionType:
	if actor.sprite_in_target_position():
		blackboard["move_finished"] = BType.ThreeStateBool.TRUE
		return BType.ActionType.SUCCESS
	else:
		var move_finished = blackboard.get("move_finished")
		if move_finished == BType.ThreeStateBool.NOTSET:
			actor.sprite_move_to_target_position()
			blackboard["move_finished"] = BType.ThreeStateBool.FALSE
			return BType.ActionType.RUNNING
		elif move_finished == BType.ThreeStateBool.FALSE:
			actor.sprite_move_to_target_position()
			return BType.ActionType.RUNNING
		else:
			print("never reach here")
			return BType.ActionType.SUCCESS
