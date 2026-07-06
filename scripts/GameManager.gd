extends Node2D

var customer_scene = preload("res://scenes/customer/Customer.tscn")

@onready var prep_station = $PrepStation
@onready var stove_station = $StoveStation
@onready var microwave_station = $MicrowaveStation
@onready var raw_steak = $IngredientShelf/RawSteak
@onready var cooked_steak = $IngredientShelf/CookedSteak
@onready var stove_area = $Stations/StoveArea
@onready var prep_area = $Stations/PrepArea
@onready var vegetables = $IngredientShelf/Vegetables
@onready var beef_plate = $IngredientShelf/BeefPlate
var prep_ingredients = []

var customers = []
var customer_slots = {}

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

func _on_station_finished(job):
	job.is_processing = false
	
	job.advance_step()
	
	if job.is_complete:

		print(job.food_name, " READY!")

		return
	
	job.waiting_for_station = true
	
	print(job.food_name, " waiting for:", job.get_current_station())
	
func _ready():
	prep_station.process_finished.connect(_on_station_finished)
	stove_station.process_finished.connect(_on_station_finished)
	microwave_station.process_finished.connect(_on_station_finished)
	
	
	for i in range(2):
		spawn_customer()
	
	# ✅ show actual coins
	$CanvasLayer/CoinLabel.text = "Coins: " + str(GameData.coins)
	$CanvasLayer/FoodPanel/BreadButton.visible = "bread" in GameData.unlocked_foods
	$CanvasLayer/FoodPanel/SteakButton.visible = "steak" in GameData.unlocked_foods

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
	
	var index = get_open_spawn_index()
	c.position = Vector2(spawn_positions[index].x, 1400)
	c.target_position = spawn_positions[index]
	
	c.served.connect(_on_customer_served)
	c.left_angry.connect(_on_customer_left_angry)
	
	customers.append(c)
	customer_slots[c] = index

func get_open_spawn_index():
	for i in range(spawn_positions.size()):
		if not customer_slots.values().has(i):
			return i

	return customers.size() % spawn_positions.size()

func _on_customer_served(customer):
	remove_customer(customer)
	spawn_customer()

func _on_customer_left_angry(customer):
	remove_customer(customer)
	spawn_customer()

func remove_customer(customer):
	customers.erase(customer)
	customer_slots.erase(customer)


func reset_combo():
	combo = 0
	combo_timer = 0
	update_combo_ui()
	print("Combo reset")

func _process(delta):
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
	#for c in customers:
		#c.stop_all()
	for c in customers:
		if is_instance_valid(c):
			c.stop_all()
	GameData.save_game()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")


func try_drop_ingredient(ingredient):

	# ---------- STOVE ----------
	var station_accepted = await try_drop_on_station(ingredient)
	if station_accepted:
		return true

	return try_drop_on_customer(ingredient)

func try_drop_on_station(ingredient):

	if stove_area.overlaps_area(ingredient):

		if ingredient.ingredient_name == "raw_steak":

			print("Cooking Steak...")

			ingredient.dragging = false

			await get_tree().create_timer(2.0).timeout

			ingredient.visible = false

			cooked_steak.food_id = ""
			cooked_steak.set_home_position(ingredient.global_position)
			cooked_steak.visible = true
			cooked_steak.monitoring = true
			cooked_steak.set_process(true)

			return true

	if prep_area.overlaps_area(ingredient):
		if not ["vegetables", "cooked_steak"].has(ingredient.ingredient_name):
			return false

		prep_ingredients.append(ingredient.ingredient_name)

		print(prep_ingredients)
		var offset = Vector2(prep_ingredients.size() * 35, 0)
		ingredient.set_home_position(prep_area.global_position + offset)
		ingredient.dragging = false

		# ===== Steak Recipe =====
		if prep_ingredients.has("vegetables") and prep_ingredients.has("cooked_steak"):

			print("Recipe Complete!")

			await get_tree().create_timer(1.0).timeout

			prep_ingredients.clear()

			#beef_plate.global_position = prep_area.global_position
			ingredient.visible = false
			vegetables.visible = false
			cooked_steak.visible = false

			beef_plate.food_id = "steak"
			beef_plate.set_home_position(prep_area.global_position)
			beef_plate.visible = true
			beef_plate.monitoring = true
			beef_plate.set_process(true)

			return true

		return true


	return false

func try_drop_on_customer(ingredient):
	if not game_active:
		return false

	for customer in customers.duplicate():
		if not is_instance_valid(customer):
			remove_customer(customer)
			continue

		if ingredient.overlaps_body(customer):
			return try_serve_customer_with_food(customer, ingredient)

	return false

func try_serve_customer_with_food(customer, food_item):
	var served_food_id = food_item.get_food_id()

	if served_food_id != customer.order:
		print("Wrong food!")
		reset_combo()
		return false

	combo += 1
	combo_timer = combo_window
	update_combo_ui()

	var reward = calculate_reward(served_food_id)
	add_coins(reward)

	print("Served:", served_food_id)

	consume_food_item(food_item)
	customer.serve()

	return true

func calculate_reward(food_id):
	if not FoodData.foods.has(food_id):
		return 0

	var base_reward = FoodData.foods[food_id]["price"]
	var bonus = 1 + (GameData.upgrades["income"] * 0.1)
	var reward = int(base_reward * bonus)

	print(
		"Food:", food_id,
		" Base:", base_reward,
		" IncomeLv:", GameData.upgrades["income"],
		" Final:", reward
	)

	return reward

func consume_food_item(food_item):
	food_item.dragging = false
	food_item.visible = false
	food_item.monitoring = false
	food_item.set_process(false)
