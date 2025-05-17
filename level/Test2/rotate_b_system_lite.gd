extends BSystemLite

func _init_call():
	insert_state("Clockwise", clockwise_state, clockwise_init)
	insert_state("CounterClockwise", counterclockwise_state, counterclockwise_init)

func clockwise_state():
	if actor.rotate_times >= 200:
		change_state("CounterClockwise")
	else:
		actor.rotate_clockwise_180()

func clockwise_init():
	pass


func counterclockwise_state():
	if actor.rotate_times == 0:
		change_state("Clockwise")
	else:
		actor.rotate_counterclockwise_180()

func counterclockwise_init():
	pass
