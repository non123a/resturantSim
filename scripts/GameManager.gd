extends Node2D

var customer_scene = preload("res://scenes/customer/Customer.tscn")

@onready var raw_steak = $IngredientShelf/RawSteak
@onready var cooked_steak = $IngredientShelf/CookedSteak
@onready var stove_area = $Stations/StoveArea
@onready var prep_area = $Stations/PrepArea
@onready var vegetables = $IngredientShelf/Vegetables
@onready var beef_plate = $IngredientShelf/BeefPlate
@onready var burger_raw_beef = $IngredientShelf/BurgerRawBeef
@onready var burger_beef = $IngredientShelf/BurgerBeef
@onready var burger_bread = $IngredientShelf/BurgerBread
@onready var burger_vegetable = $IngredientShelf/BurgerVegetable
@onready var burger_sauce = $IngredientShelf/BurgerSauce
@onready var burger_bread_vegetable = $IngredientShelf/BurgerBreadVegetable
@onready var burger_bread_vegetable_sauce = $IngredientShelf/BurgerBreadVegetableSauce
@onready var burger_bread_beef = $IngredientShelf/BurgerBreadBeef
@onready var burger_bread_beef_sauce = $IngredientShelf/BurgerBreadBeefSauce
@onready var burger_bread_vegetable_beef = $IngredientShelf/BurgerBreadVegetableBeef
@onready var burger = $IngredientShelf/Burger
@onready var donut = $IngredientShelf/Donut
@onready var burrito = $IngredientShelf/Burrito
@onready var jelly = $IngredientShelf/Jelly
var prep_ingredients = []

var customers = []
var customer_slots = {}

var run_coins = 0 

var time_left = 60.0
var game_active = true


var combo = 0
var combo_timer = 0.0
var combo_window = 10.0  # seconds to keep combo alive

func _ready():
	for i in range(2):
		spawn_customer()
	
	# ✅ show actual coins
	$CanvasLayer/CoinLabel.text = "Coins: " + str(GameData.coins)
	update_progression_food_visibility()

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

func update_progression_food_visibility():
	var steak_unlocked = GameData.is_food_unlocked("steak")
	raw_steak.visible = steak_unlocked
	vegetables.visible = steak_unlocked

	var burger_unlocked = GameData.is_food_unlocked("burger")
	burger_raw_beef.visible = burger_unlocked
	burger_bread.visible = burger_unlocked
	burger_vegetable.visible = burger_unlocked
	burger_sauce.visible = burger_unlocked

	donut.visible = GameData.is_food_unlocked("donut")
	burrito.visible = GameData.is_food_unlocked("burrito")
	jelly.visible = GameData.is_food_unlocked("jelly")


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
	if combo > 0:
		combo_timer -= delta
		
		if combo_timer <= 0:
			reset_combo()


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
	
	# ✅ SAVE BEST RECORD (ONLY THIS)
	if run_coins > GameData.best_coins:
		GameData.best_coins = run_coins
		print("NEW RECORD!")
	
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
		return await try_process_single_input_recipe("stove", ingredient)

	if prep_area.overlaps_area(ingredient):
		var ingredient_name = ingredient.get_ingredient_name()
		if not RecipeData.can_accept_ingredient("prep", prep_ingredients, ingredient_name):
			return false

		prep_ingredients.append(ingredient_name)

		print(prep_ingredients)
		var offset = Vector2(prep_ingredients.size() * 35, 0)
		ingredient.set_home_position(prep_area.global_position + offset)
		ingredient.dragging = false

		var recipe = RecipeData.get_recipe("prep", prep_ingredients)
		if not recipe.is_empty():
			await process_recipe(recipe, prep_area.global_position)
			prep_ingredients.clear()

			return true

		return true


	return false

func try_process_single_input_recipe(station, ingredient):
	var ingredient_name = ingredient.get_ingredient_name()
	if not RecipeData.can_accept_ingredient(station, [], ingredient_name):
		return false

	var recipe = RecipeData.get_recipe(station, [ingredient_name])
	if recipe.is_empty():
		return false

	ingredient.dragging = false

	await process_recipe(recipe, ingredient.global_position)

	return true

func process_recipe(recipe, output_position):
	print("Processing recipe:", recipe["recipe_id"])

	await get_tree().create_timer(recipe["duration"]).timeout

	clear_recipe_inputs(recipe)

	var output = get_ingredient_node(recipe["output_ingredient"])
	if output == null:
		return

	output.food_id = recipe["output_food_id"]
	output.set_home_position(output_position)
	output.visible = true
	output.monitoring = true
	output.set_process(true)

func clear_recipe_inputs(recipe):
	for input in recipe["inputs"]:
		var ingredient = get_ingredient_node(input)
		if ingredient == null:
			continue

		ingredient.visible = false

func get_ingredient_node(ingredient_name):
	match ingredient_name:
		"raw_steak":
			return raw_steak
		"cooked_steak":
			return cooked_steak
		"vegetables":
			return vegetables
		"beef_plate":
			return beef_plate
		"burger_raw_beef":
			return burger_raw_beef
		"burger_beef":
			return burger_beef
		"burger_bread":
			return burger_bread
		"burger_vegetable":
			return burger_vegetable
		"burger_sauce":
			return burger_sauce
		"burger_bread_vegetable":
			return burger_bread_vegetable
		"burger_bread_vegetable_sauce":
			return burger_bread_vegetable_sauce
		"burger_bread_beef":
			return burger_bread_beef
		"burger_bread_beef_sauce":
			return burger_bread_beef_sauce
		"burger_bread_vegetable_beef":
			return burger_bread_vegetable_beef
		"burger":
			return burger
		"donut":
			return donut
		"burrito":
			return burrito
		"jelly":
			return jelly
		_:
			return null

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
