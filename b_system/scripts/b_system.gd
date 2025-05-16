class_name BSystem extends BNode

@export var actor: Node
@export var blackboard: Dictionary = {}
@export var init_state: String

func _ready():
	change_state(init_state)

func _physics_process(_delta: float) -> void:
	var current_state = blackboard.get("current_state")
	for child in get_children():
		if child is BComposite and "State_" + child.state == current_state:
			last_action_type = child._run(actor, blackboard, change_state)




func change_state(state: String):
	blackboard["current_state"] = "State_" + state
	for child in get_children():
		print("child:", child.state)
		if child is BStateComposite and child.state == state:
			child._init_when_change_state(actor, blackboard)
