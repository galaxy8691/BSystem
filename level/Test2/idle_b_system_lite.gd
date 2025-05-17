extends BSystemLite

func _init_call():
	insert_state("Idle", idle_state, idle_init)
	insert_state("Move", move_state, move_init)

func idle_state():
	var is_playing_finished = blackboard.get("idle_animation_finished")
	if is_playing_finished == BType.ThreeStateBool.NOTSET:
		actor.play_idle()
		blackboard["idle_animation_finished"] = BType.ThreeStateBool.FALSE
	elif is_playing_finished == BType.ThreeStateBool.FALSE:
		return
	else:
		print("tell idle animation finished")
		blackboard["idle_animation_finished"] = BType.ThreeStateBool.NOTSET

func idle_init():
	blackboard["idle_animation_finished"] = BType.ThreeStateBool.NOTSET

func move_state():
	actor.stop_animation()
	if actor.sprite_in_target_position():
		blackboard["move_finished"] = BType.ThreeStateBool.TRUE
		change_state("Idle")
	else:
		var move_finished = blackboard.get("move_finished")
		if move_finished == BType.ThreeStateBool.NOTSET:
			actor.sprite_move_to_target_position()
			blackboard["move_finished"] = BType.ThreeStateBool.FALSE
		elif move_finished == BType.ThreeStateBool.FALSE:
			actor.sprite_move_to_target_position()

func move_init():
	blackboard["move_finished"] = BType.ThreeStateBool.NOTSET