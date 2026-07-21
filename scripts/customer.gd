extends CharacterBody2D

signal served(customer)
signal left_angry(customer)

var speed = 100
var target_position = Vector2(360, 500)
var state = "walking"
var has_left = false

var order = ""


var patience = 10.0
var max_patience = 10.0

func _ready():
	order = GameData.get_random_order_food()
	print("Customer wants:", order)

	if GameData.foods.has(order):
		max_patience = GameData.foods[order]["wait_time"]

	patience = max_patience
	$ProgressBar.max_value = max_patience
	$ProgressBar.value = patience
	$ThoughtBubble.show_food(order)
	
	$AnimatedSprite2D.play("walkingInAnimation")
	

func _physics_process(delta):
	if state == "stopped":
		return
	
	if state == "walking":
		move_to_target(delta)
	elif state == "waiting":
		wait_for_food(delta)

@warning_ignore("unused_parameter")
func move_to_target(delta):
	var direction = (target_position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	if position.distance_to(target_position) < 5:
		arrive()


var grace_time = 1.5
var grace_timer = 0.0

func arrive():
	state = "waiting"
	velocity = Vector2.ZERO
	
	$AnimatedSprite2D.stop() 

func wait_for_food(delta):
	if has_left:
		return

	if grace_timer > 0:
		grace_timer -= delta
		return   # ⬅️ no patience loss yet
	
	patience -= delta
	$ProgressBar.value = max(patience, 0)
	
	if patience <= 0:
		leave_angry()
func serve():
	leave_happy()

func leave_happy():
	if has_left:
		return

	has_left = true
	print("Customer happy")
	served.emit(self)
	queue_free()

func leave_angry():
	if has_left:
		return

	has_left = true
	print("Customer angry")
	left_angry.emit(self)
	queue_free()

func stop_all():
	state = "stopped"
	velocity = Vector2.ZERO
	
	$AnimatedSprite2D.stop()
