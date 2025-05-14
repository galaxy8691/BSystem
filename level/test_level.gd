extends Node2D

var rotate_times: int = 0
var rotate_max_times: int = 3
@onready var sprite: Sprite2D = $Sprite2D

func move_a_little():
	position.x += 10
	position.y += 10

func move_a_lot():
	position.x += 100
	position.y += 100

func rotate_clockwise_180():
	sprite.rotate(PI/2 * get_physics_process_delta_time())
	rotate_times += 1

func rotate_counterclockwise_180():
	sprite.rotate(-PI/2 * get_physics_process_delta_time())
	rotate_times -= 1

# func _process(_delta: float) -> void:
# 	rotate_clockwise_180()

