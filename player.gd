extends CharacterBody2D

@export var speed = 200
@export var gravity = 30
@export var jump_force = 300

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D

enum States {AIR, FLOOR, WALL}

var was_on_floor = false # Keep track of whether the character was on the floor in the previous frame
var jumps = 0
const MAX_JUMPS = 2

const wall_jump_pushback = 800

func _physics_process(delta):
	
	var horizontal_direction = Input.get_axis("move_left","move_right")
	velocity.x = speed * horizontal_direction
	
	if horizontal_direction != 0 and !is_on_wall_only():
		sprite.flip_h = (horizontal_direction == -1)
	
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000
			
	else:
		jumps = 0
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_force
			jumps += 1
		if jumps < MAX_JUMPS and !is_on_floor() and !is_on_wall(): #Check for Double Jump
			velocity.y = -jump_force
			jumps += 1
			
		#Wall Jump
		if is_on_wall_only() and Input.is_action_pressed("move_right"):
			velocity.y = -jump_force
			velocity.x = -wall_jump_pushback
		if is_on_wall_only() and Input.is_action_pressed("move_left"):
			velocity.y = -jump_force
			velocity.x = wall_jump_pushback
			
	if is_on_wall_only() and Input.is_action_pressed("wall_hold"):
			velocity.x = 0
			velocity.y = 0
			
	# Check for landing
	if !was_on_floor and is_on_floor():
		ap.play("land")
	else:
		update_animations(horizontal_direction)
	
	was_on_floor = is_on_floor() # Update was_on_floor for the next frame
	
	move_and_slide()
	
	print(is_on_wall_only())
	

func update_animations(horizontal_direction):
	if is_on_floor():
		if horizontal_direction == 0:
			if ap.current_animation != "idle" and ap.current_animation != "land":
				ap.play("idle")
		else:
			if ap.current_animation != "run":
				ap.play("run")
	elif is_on_wall_only():
		ap.play("wall_land")
	else:
		if velocity.y < 0 and ap.current_animation != "jump":
			if jumps == 2 and !is_on_wall():
				ap.play("double_jump")
			else:
				ap.play("jump")
