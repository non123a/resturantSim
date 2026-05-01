extends CharacterBody2D

var speed = 100
var target_position = Vector2(360, 500)
var game_manager = null
var state = "walking"

var order = ""


var patience = 10.0
var max_patience = 10.0

#func _ready():
	#$OrderLabel.text = order
#
	#$ProgressBar.max_value = max_patience
	#order = ["fish", "shrimp"].pick_random()
	#print("Customer wants:", order)
	#$AnimatedSprite2D.play("walkingInAnimation")
func _ready():
	$ProgressBar.max_value = max_patience
	
	order = ["fish", "shrimp"].pick_random()
	print("Customer wants:", order)

	$OrderLabel.text = order   # ✅ AFTER setting order
	
	$AnimatedSprite2D.play("walkingInAnimation")
	print("Label text:", $OrderLabel.text)
	
func _physics_process(delta):
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
	print("Customer happy")
	queue_free()

func leave_angry():
	print("Customer angry")
	queue_free()

@warning_ignore("unused_parameter")

func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) \
	or (event is InputEventScreenTouch and event.pressed):

		if game_manager.food_ready:
			game_manager.serve_food(self)
