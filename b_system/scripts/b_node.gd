class_name BNode extends Node
var last_action_type: BType.ActionType = BType.ActionType.NOTSET


func _run(actor: Node, blackboard: Dictionary) -> BType.ActionType:
	last_action_type = tick(actor, blackboard)
	return last_action_type

func tick(_actor: Node, _blackboard: Dictionary) -> BType.ActionType:
	return BType.ActionType.NOTSET

func clear():
	last_action_type = BType.ActionType.NOTSET
	for child in get_children():
		if child is BNode:
			child.clear()

func set_current_state(state: String):
	if self is BSystem:
		system_change_state(state)
	else:
		get_parent().set_current_state(state)

func system_change_state(_state: String):
	pass

func _set_system_blackboard(key: String, value: Variant):
	pass

func _get_system_blackboard(key: String):
	pass

func set_blackboard(key: String, value: Variant):
	if self is BSystem:
		_set_system_blackboard(key, value)
	else:
		get_parent().set_blackboard(key, value)

func get_blackboard(key: String):
	if self is BSystem:
		return _get_system_blackboard(key)
	else:
		return get_parent().get_blackboard(key)
