extends Node

@export var station_type = ""
var is_busy = false

var current_food = ""
var timer = 0.0

var current_job = null

signal process_finished(job)


func start_process(job, process_time):
	if is_busy:
		return false
	
	is_busy = true
	
	current_job = job
	current_food = job.food_name
	
	timer = process_time
	
	print(station_type, " started:", current_food)
	
	return true
	
func _process(delta):
	if is_busy:
		timer -= delta
		
		if timer <= 0:
			finish_process()


#func finish_process():
	#is_busy = false
	#
	#print(station_type, " finished:", current_food)
	#
	#current_food = ""
#

func finish_process():
	is_busy = false
	
	print(station_type, " finished:", current_food)
	
	emit_signal("process_finished", current_job)
	
	current_food = ""
	current_job = null
