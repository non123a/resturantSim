extends Node

var food_name = ""
var steps = []

var current_step = 0
var is_complete = false
var waiting_for_station = false

var is_processing = false

#func setup(name, food_steps):
func setup(food_id, food_steps):
	#food_name = name
	food_name = food_id
	steps = food_steps


func get_current_station():
	if current_step >= steps.size():
		return ""
	
	return steps[current_step]


func advance_step():
	current_step += 1
	
	if current_step >= steps.size():
		is_complete = true
