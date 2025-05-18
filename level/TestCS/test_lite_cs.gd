extends Node2D

var rotate_times: int = 0
var rotate_max_times: int = 3
@onready var sprite: Sprite2D = $Sprite2D
var target_position: Vector2 = Vector2(0, 0)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var idle_b_system:BSystemLiteCs = $IdleBSystemLiteCs

func _ready():
	print("test_lite_cs _ready")
	animation_player.animation_finished.connect(func(animation_name: String):
		if animation_name == "idle":
			idle_b_system.SetAnimationFinished()

	)


	#cs

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


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("click"):
		target_position = get_global_mouse_position()
		idle_b_system.ChangeState("Move")

func sprite_move_to_target_position():
	sprite.position = sprite.position.move_toward(target_position, 100 * get_physics_process_delta_time())

func sprite_in_target_position():
	return sprite.position.distance_to(target_position) < 10

func play_idle():
	animation_player.play("idle")

func stop_animation():
	animation_player.stop()
