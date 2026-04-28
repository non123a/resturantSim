extends Node

var cook_time = 3.0
var is_cooking = false
var timer = 0.0

func start_cooking():
	is_cooking = true
	timer = cook_time
	print("Cooking started")

func _process(delta):
	if is_cooking:
		timer -= delta
		if timer <= 0:
			finish_cooking()

func finish_cooking():
	is_cooking = false
	print("Food ready")
