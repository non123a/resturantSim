extends Node2D

var customer_scene = preload("res://scenes/customer/Customer.tscn")

@onready var prep_station = $PrepStation
@onready var stove_station = $StoveStation


var selected_food = ""
var active_jobs = []

var customers = []

var run_coins = 0 

var food_types = ["fish", "shrimp"]
var current_food = ""

var round_time = 60.0
var time_left = 60.0
var game_active = true


var combo = 0
var combo_timer = 0.0
var combo_window = 10.0  # seconds to keep combo alive

var food_ready = false
var cooking = false
var cook_time = 2.0
var timer = 0.0


#func _on_station_finished(job):
	#job.is_processing = false
	#job.advance_step()
	#
	#if job.is_complete:
		#print(job.food_name, " READY!")
func _on_station_finished(job):
	job.is_processing = false
	
	job.advance_step()
	
	if job.is_complete:
		print(job.food_name, " READY!")
		return
	
	job.waiting_for_station = true
	
	print(job.food_name, " waiting for:", job.get_current_station())
	
func _ready():
	selected_food = "burger"
	prep_station.process_finished.connect(_on_station_finished)
	stove_station.process_finished.connect(_on_station_finished)
	
	
	for i in range(2):
		spawn_customer()
	
	# ✅ show actual coins
	$CanvasLayer/CoinLabel.text = "Coins: " + str(GameData.coins)

func process_jobs():
	for job in active_jobs:
		
		#if job.is_complete:
			#continue
		#if job.is_complete or job.is_processing:
			#continue
		if job.is_complete or job.is_processing or job.waiting_for_station:
			continue
		
		var needed_station = job.get_current_station()
		
		if needed_station == "prep":
			
			if not prep_station.is_busy:
				#prep_station.start_process(job.food_name, 2.0)
				prep_station.start_process(job, 2.0)
				
		
		
		elif needed_station == "stove":
			
			if not stove_station.is_busy:
				#stove_station.start_process(job.food_name, 3.0)
				stove_station.start_process(job, 3.0)
			
				

var spawn_positions = [
	Vector2(200, 500),
	Vector2(360, 500),
	Vector2(520, 500)
]

func spawn_customer():
	if not game_active:
		return
	var c = customer_scene.instantiate()
	add_child(c)
	
	var index = customers.size() % spawn_positions.size()
	c.position = Vector2(spawn_positions[index].x, 1400)
	c.target_position = spawn_positions[index]
	
	c.game_manager = self
	
	customers.append(c)


func reset_combo():
	combo = 0
	combo_timer = 0
	update_combo_ui()
	print("Combo reset")

func _process(delta):
	process_jobs()
	if game_active:
		time_left -= delta
		
		if time_left <= 0:
			end_game()
		
		$CanvasLayer/TimerLabel.text = "Time: " + str(int(time_left))
	if combo > 0 and not cooking:
		combo_timer -= delta
		
		if combo_timer <= 0:
			reset_combo()
	if cooking:
		timer -= delta
		
		var progress = (1 - (timer / cook_time)) * 100
		$CanvasLayer/CookingBar.value = progress
		
		print("Progress:", progress)   # debug
		
		if timer <= 0:
			cooking = false
			food_ready = true
			$CanvasLayer/CookingBar.visible = false
			
			print("Food Ready!")
			
			$CanvasLayer/CookFishButton.text = "Fish"
			$CanvasLayer/CookShrimpButton.text = "Shrimp"

		
func start_cooking(food_type):
	$CanvasLayer/CookingBar.visible = true
	$CanvasLayer/CookingBar.value = 0
	if not game_active:
		return
	if not cooking and not food_ready:
		cooking = true
		#timer = cook_time
		var speed_bonus = GameData.upgrades["cook_speed"] * 0.3
		timer = max(0.5, cook_time - speed_bonus)
		
		current_food = food_type
		
		print("Cooking:", current_food)
		
		$CanvasLayer/CookFishButton.text = "Cooking fish..."
		$CanvasLayer/CookShrimpButton.text = "Cooking shrimp..."

func serve_food(customer):
	if not game_active:
		return
	if not food_ready or customer == null:
		return
	
	if current_food == customer.order:
		customer.serve()
		
		combo += 1
		combo_timer = combo_window
		update_combo_ui()
		
		#var reward = 10 + (combo * 2)
		var base_reward = 10 + (combo * 2)
		var bonus = 1 + (GameData.upgrades["income"] * 0.1)

		var reward = int(base_reward * bonus)
		add_coins(reward)
		
		print("Correct! Combo:", combo, "Reward:", reward)
	else:
		print("Wrong order!")
		customer.leave_angry()
		reset_combo()
	
	# Reset cooking state
	food_ready = false
	
	$CanvasLayer/CookFishButton.text = "Fish"
	$CanvasLayer/CookShrimpButton.text = "Shrimp"
	
	customers.erase(customer)
	spawn_customer()
	
	
func _on_cook_shrimp_button_pressed():
	start_cooking("shrimp")

func _on_cook_fish_button_pressed() -> void:
	start_cooking("fish")


func add_coins(amount):
	run_coins += amount
	GameData.coins += amount
	
	print("Run Coins:", run_coins)
	print("Total Coins:", GameData.coins)
	
	$CanvasLayer/CoinLabel.text = "Coins: " + str(GameData.coins)

func update_combo_ui():
	if combo > 0:
		$CanvasLayer/ComboLabel.visible = true
		$CanvasLayer/ComboLabel.text = "🔥 Combo x" + str(combo)
	else:
		$CanvasLayer/ComboLabel.visible = false


func end_game():
	game_active = false
	
	print("Game Over!")
	print("Run Coins:", run_coins)
	
	cooking = false
	food_ready = false
	
	# ✅ SAVE BEST RECORD (ONLY THIS)
	if run_coins > GameData.best_coins:
		GameData.best_coins = run_coins
		print("NEW RECORD!")
	
	$CanvasLayer/CookFishButton.disabled = true
	$CanvasLayer/CookShrimpButton.disabled = true
	
	# ✅ SHOW CORRECT DATA
	$CanvasLayer/EndPanel.visible = true
	$CanvasLayer/EndPanel/ResultLabel.text = \
		"Run: " + str(run_coins) + \
		"\nBest: " + str(GameData.best_coins)
	for c in customers:
		c.stop_all()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


#func _on_stove_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#if event is InputEventMouseButton and event.pressed:
		#print("Stove clicked")
func _on_stove_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		
		for job in active_jobs:
			
			if job.waiting_for_station:
				
				if job.get_current_station() == "stove":
					
					job.waiting_for_station = false
					
					stove_station.start_process(job, 3.0)
					
					job.is_processing = true
					
					print(job.food_name, " sent to stove")
					
					return
					
func _on_prep_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		
		if selected_food == "":
			return
		
		var data = FoodData.foods[selected_food]
		
		var job = preload("res://scripts/FoodJob.gd").new()
		
		job.setup(selected_food, data["steps"])
		
		active_jobs.append(job)
		selected_food = ""
		
		print(selected_food, " sent to prep")


func _on_burger_button_pressed():
	selected_food = "burger"
	print("Selected:", selected_food)

func _on_steak_button_pressed():
	selected_food = "steak"
	print("Selected:", selected_food)

func _on_donut_button_pressed():
	selected_food = "donut"
	print("Selected:", selected_food)
