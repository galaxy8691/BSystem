extends BSequence

func _init_when_change_state(actor: Node, blackboard: Dictionary) -> void:
	set_blackboard("idle_animation_finished", BType.ThreeStateBool.NOTSET)
