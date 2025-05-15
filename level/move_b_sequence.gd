extends BStateSequence

func _init_when_change_state(actor: Node, blackboard: Dictionary) -> void:
	set_blackboard("move_finished", BType.ThreeStateBool.NOTSET)
