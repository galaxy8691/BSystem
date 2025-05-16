extends BStateSequence

func _init_when_change_state(actor: Node, blackboard: Dictionary) -> void:
	blackboard["move_finished"] = BType.ThreeStateBool.NOTSET
	print("init move")
