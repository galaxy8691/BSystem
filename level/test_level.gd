extends Node2D

var rotate_times: int = 0
var rotate_max_times: int = 3

func move_a_little():
	position.x += 10
	position.y += 10

func move_a_lot():
	position.x += 100
	position.y += 100

func rotate_clockwise_180():
	rotate(PI/2)
	rotate_times += 1

func rotate_counterclockwise_180():
	rotate(-PI/2)
	rotate_times += 1

