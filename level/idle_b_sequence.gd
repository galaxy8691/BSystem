extends BStateSequence

func _init_when_change_state(actor: Node, blackboard: Dictionary) -> void:
	blackboard["idle_animation_finished"] = BType.ThreeStateBool.NOTSET
