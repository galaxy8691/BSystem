class_name BSystem extends BNode

@export var actor: Node
@export var blackboard: Dictionary = {}
@export var current_state: String = &"State_"


func _physics_process(_delta: float) -> void:
	for child in get_children():
		if child is BComposite and child.state == current_state:
			last_action_type = child.tick(actor, blackboard)
			if last_action_type == BType.ActionType.FAILURE or last_action_type == BType.ActionType.SUCCESS:
				clear()
				break

