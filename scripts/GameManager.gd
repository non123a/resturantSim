extends Node2D

var customer_scene = preload("res://scenes/customer/Customer.tscn")

@export var customer_spawn_delay_min = 0.8
@export var customer_spawn_delay_max = 1.6

@onready var stove_area = $Stations/StoveArea
@onready var prep_slots = [
	$Stations/PrepSlot1,
	$Stations/PrepSlot2,
	$Stations/PrepSlot3,
	$Stations/PrepSlot4
]
@onready var ingredient_shelf = $IngredientShelf
var ingredient_templates = {}
var prep_slot_ingredient_instances = {}
var prep_slot_busy_states = {}
var prep_ingredient_slot_owners = {}

var customers = []
var customer_slots = {}
var pending_customer_spawns = 0

var run_coins = 0 

var time_left = 60.0
var game_active = true


var combo = 0
var combo_timer = 0.0
var combo_window = 10.0  # seconds to keep combo alive

func _ready():
	initialize_ingredient_registry()
	initialize_prep_slots()

	spawn_customers_to_target()
	
	# ✅ show actual coins
	$CanvasLayer/CoinLabel.text = "Coins: " + str(GameData.coins)
	update_progression_food_visibility()

func initialize_prep_slots():
	for slot in prep_slots:
		prep_slot_ingredient_instances[slot] = []
		prep_slot_busy_states[slot] = false

func initialize_ingredient_registry():
	ingredient_templates.clear()

	for ingredient in ingredient_shelf.get_children():
		if not ingredient.has_method("get_ingredient_name"):
			continue

		var ingredient_id = ingredient.get_ingredient_name()
		if ingredient_id == "":
			continue

		ingredient_templates[ingredient_id] = ingredient

var spawn_positions = [
	Vector2(0, 250),
	Vector2(200, 250),
	Vector2(400, 250)
]

func spawn_customer():
	if not game_active:
		return
	var c = customer_scene.instantiate()
	add_child(c)
	
	var index = get_open_spawn_index()
	c.position = Vector2(spawn_positions[index].x, 0)
	c.target_position = spawn_positions[index]
	
	c.served.connect(_on_customer_served)
	c.left_angry.connect(_on_customer_left_angry)
	
	customers.append(c)
	customer_slots[c] = index

func spawn_customers_to_target():
	var target_count = get_customer_target_count()
	while customers.size() < target_count:
		spawn_customer()

func queue_replacement_customer():
	if customers.size() + pending_customer_spawns >= get_customer_target_count():
		return

	pending_customer_spawns += 1
	var spawn_delay = randf_range(customer_spawn_delay_min, customer_spawn_delay_max)
	await get_tree().create_timer(spawn_delay).timeout
	pending_customer_spawns -= 1

	if game_active and customers.size() + pending_customer_spawns < get_customer_target_count():
		spawn_customer()

func get_customer_target_count():
	if GameData.is_food_unlocked("burrito"):
		return 3

	return 2

func get_open_spawn_index():
	for i in range(spawn_positions.size()):
		if not customer_slots.values().has(i):
			return i

	return customers.size() % spawn_positions.size()

func _on_customer_served(customer):
	remove_customer(customer)
	queue_replacement_customer()

func _on_customer_left_angry(customer):
	remove_customer(customer)
	queue_replacement_customer()

func remove_customer(customer):
	customers.erase(customer)
	customer_slots.erase(customer)

func update_progression_food_visibility():
	var steak_unlocked = GameData.is_food_unlocked("steak")
	set_ingredient_visible("raw_steak", steak_unlocked)
	set_ingredient_visible("vegetables", steak_unlocked)

	var burger_unlocked = GameData.is_food_unlocked("burger")
	set_ingredient_visible("burger_raw_beef", burger_unlocked)
	set_ingredient_visible("burger_bread", burger_unlocked)
	set_ingredient_visible("burger_vegetable", burger_unlocked)
	set_ingredient_visible("burger_sauce", burger_unlocked)

	var burrito_unlocked = GameData.is_food_unlocked("burrito")
	set_ingredient_visible("burrito_meat", burrito_unlocked)
	set_ingredient_visible("burrito_rice", burrito_unlocked)
	set_ingredient_visible("burrito_vegetable", burrito_unlocked)

	set_ingredient_visible("donut", GameData.is_food_unlocked("donut"))
	set_ingredient_visible("jelly", GameData.is_food_unlocked("jelly"))

func set_ingredient_visible(ingredient_id, visible):
	var ingredient = get_ingredient_node(ingredient_id)
	if ingredient == null:
		return

	ingredient.visible = visible

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

	var prep_slot = get_overlapping_prep_slot(ingredient)
	if prep_slot != null:
		return await try_drop_on_prep_slot(prep_slot, ingredient)


	return false

func get_overlapping_prep_slot(ingredient):
	for slot in prep_slots:
		if slot.overlaps_area(ingredient):
			return slot

	return null

func try_drop_on_prep_slot(slot, ingredient):
	if prep_slot_busy_states[slot]:
		log_prep_slot(slot, "drop rejected, slot busy", [ingredient.get_ingredient_name()])
		return false

	cleanup_all_prep_slots()
	cleanup_prep_slot(slot)

	var current_owner = get_prep_slot_for_ingredient(ingredient)
	if current_owner == slot:
		ingredient.set_home_position(get_prep_slot_item_position(slot, prep_slot_ingredient_instances[slot].find(ingredient) + 1))
		ingredient.dragging = false
		var current_ingredients = get_prep_slot_contents(slot)
		var owned_recipe = RecipeData.get_recipe("prep", current_ingredients)
		if not owned_recipe.is_empty():
			await process_prep_recipe(slot, owned_recipe, prep_slot_ingredient_instances[slot].duplicate())
			return true

		log_prep_slot(slot, "drop ignored, ingredient already owned", get_prep_slot_contents(slot))
		return true

	var ingredient_name = ingredient.get_ingredient_name()
	var prep_ingredient_names = get_ingredient_names(prep_slot_ingredient_instances[slot])
	if not RecipeData.can_accept_ingredient("prep", prep_ingredient_names, ingredient_name):
		log_prep_slot(slot, "drop rejected, no recipe accepts", prep_ingredient_names + [ingredient_name])
		return false

	assign_ingredient_to_prep_slot(slot, ingredient)
	var slot_ingredients = prep_slot_ingredient_instances[slot]
	prep_ingredient_names.append(ingredient_name)

	ingredient.set_home_position(get_prep_slot_item_position(slot, slot_ingredients.size()))
	ingredient.dragging = false
	log_prep_slot(slot, "current ingredients", prep_ingredient_names)

	var recipe = RecipeData.get_recipe("prep", prep_ingredient_names)
	if not recipe.is_empty():
		var input_instances = slot_ingredients.duplicate()
		await process_prep_recipe(slot, recipe, input_instances)

		return true

	return true

func get_prep_slot_item_position(slot, item_count):
	match item_count:
		1:
			return slot.global_position + Vector2(-24, 0)
		2:
			return slot.global_position + Vector2(24, 0)
		3:
			return slot.global_position + Vector2(0, 24)
		_:
			return slot.global_position

func process_prep_recipe(slot, recipe, input_instances):
	prep_slot_busy_states[slot] = true
	log_prep_slot(slot, "recipe matched", recipe["recipe_id"])
	log_prep_slot(slot, "ingredients consumed", get_ingredient_names(input_instances))

	lock_ingredient_instances(input_instances)

	await get_tree().create_timer(get_recipe_duration(recipe)).timeout

	consume_ingredient_instances(input_instances)
	prep_slot_ingredient_instances[slot] = []

	var output = spawn_ingredient_instance(
		recipe["output_ingredient"],
		recipe["output_food_id"],
		slot.global_position
	)
	if output != null:
		assign_ingredient_to_prep_slot(slot, output)
		log_prep_slot(slot, "output spawned", [output.get_ingredient_name()])

		var auto_recipe = get_auto_prep_recipe(slot)
		if not auto_recipe.is_empty():
			await process_prep_recipe(slot, auto_recipe, prep_slot_ingredient_instances[slot].duplicate())
			return
	else:
		log_prep_slot(slot, "output spawn failed", [recipe["output_ingredient"]])

	prep_slot_busy_states[slot] = false
	log_prep_slot(slot, "slot contents after processing", get_prep_slot_contents(slot))

func get_auto_prep_recipe(slot):
	var recipe = RecipeData.get_recipe("prep", get_prep_slot_contents(slot))
	if recipe.is_empty():
		return {}

	if not recipe.get("auto_process", false):
		return {}

	return recipe

func lock_ingredient_instances(ingredient_instances):
	for ingredient in ingredient_instances:
		if ingredient == null or not is_instance_valid(ingredient):
			continue

		ingredient.dragging = false
		ingredient.monitoring = false
		ingredient.input_pickable = false

func get_prep_slot_for_ingredient(ingredient):
	cleanup_all_prep_slots()

	if prep_ingredient_slot_owners.has(ingredient):
		var owner = prep_ingredient_slot_owners[ingredient]
		if prep_slots.has(owner) and prep_slot_ingredient_instances[owner].has(ingredient):
			return owner

		prep_ingredient_slot_owners.erase(ingredient)

	for slot in prep_slots:
		if prep_slot_ingredient_instances[slot].has(ingredient):
			prep_ingredient_slot_owners[ingredient] = slot
			return slot

	return null

func assign_ingredient_to_prep_slot(slot, ingredient):
	remove_ingredient_from_prep_slots(ingredient)

	if not prep_slot_ingredient_instances[slot].has(ingredient):
		prep_slot_ingredient_instances[slot].append(ingredient)

	prep_ingredient_slot_owners[ingredient] = slot
	log_prep_slot(slot, "ingredient assigned", [ingredient.get_ingredient_name()])

func remove_ingredient_from_prep_slots(ingredient):
	var removed_from_slot = null

	for slot in prep_slots:
		cleanup_prep_slot(slot)
		if prep_slot_ingredient_instances[slot].has(ingredient):
			prep_slot_ingredient_instances[slot].erase(ingredient)
			if removed_from_slot == null:
				removed_from_slot = slot

	prep_ingredient_slot_owners.erase(ingredient)

	if removed_from_slot != null:
		log_prep_slot(removed_from_slot, "ingredient removed from slot", [ingredient.get_ingredient_name()])

func cleanup_all_prep_slots():
	for slot in prep_slots:
		cleanup_prep_slot(slot)

func cleanup_prep_slot(slot):
	var valid_ingredients = []
	for ingredient in prep_slot_ingredient_instances[slot]:
		if ingredient == null or not is_instance_valid(ingredient):
			prep_ingredient_slot_owners.erase(ingredient)
			continue

		var owner = prep_ingredient_slot_owners.get(ingredient)
		if owner == null:
			prep_ingredient_slot_owners[ingredient] = slot
			valid_ingredients.append(ingredient)
		elif owner == slot:
			valid_ingredients.append(ingredient)

	prep_slot_ingredient_instances[slot] = valid_ingredients

func get_prep_slot_contents(slot):
	cleanup_prep_slot(slot)
	return get_ingredient_names(prep_slot_ingredient_instances[slot])

func log_prep_slot(slot, message, data):
	print("[", slot.name, "] ", message, ": ", data)

func try_process_single_input_recipe(station, ingredient):
	var ingredient_name = ingredient.get_ingredient_name()
	if not RecipeData.can_accept_ingredient(station, [], ingredient_name):
		return false

	var recipe = RecipeData.get_recipe(station, [ingredient_name])
	if recipe.is_empty():
		return false

	ingredient.dragging = false
	remove_ingredient_from_prep_slots(ingredient)

	await process_recipe(recipe, ingredient.global_position, [ingredient])

	return true

func process_recipe(recipe, output_position, input_instances):
	print("Processing recipe:", recipe["recipe_id"])

	await get_tree().create_timer(get_recipe_duration(recipe)).timeout

	consume_ingredient_instances(input_instances)

	var output = spawn_ingredient_instance(
		recipe["output_ingredient"],
		recipe["output_food_id"],
		output_position
	)
	if output == null:
		return

func consume_ingredient_instances(ingredient_instances):
	for ingredient in ingredient_instances:
		if ingredient == null or not is_instance_valid(ingredient):
			continue

		if ingredient.is_source:
			continue

		ingredient.dragging = false
		remove_ingredient_from_prep_slots(ingredient)
		ingredient.queue_free()

func get_ingredient_names(ingredient_instances):
	var ingredient_names = []
	for ingredient in ingredient_instances:
		if ingredient == null or not is_instance_valid(ingredient):
			continue

		ingredient_names.append(ingredient.get_ingredient_name())

	return ingredient_names

func spawn_ingredient_instance(ingredient_name, food_id, output_position):
	var template = get_ingredient_node(ingredient_name)
	if template == null:
		return null

	var instance = template.duplicate()
	template.get_parent().add_child(instance)
	instance.is_source = false
	instance.food_id = food_id
	instance.visible = true
	instance.monitoring = true
	instance.input_pickable = true
	instance.set_process(true)
	instance.set_process_input(true)
	instance.set_home_position(output_position)

	return instance

func get_ingredient_node(ingredient_name):
	return ingredient_templates.get(ingredient_name)

func get_recipe_duration(recipe):
	var cook_speed_level = min(GameData.upgrades["cook_speed"], 5)
	var speed_bonus = min(cook_speed_level * 0.07, 0.35)
	return recipe["duration"] * (1.0 - speed_bonus)

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

	remove_ingredient_from_prep_slots(food_item)
	consume_food_item(food_item)
	customer.serve()

	return true

func calculate_reward(food_id):
	if not GameData.foods.has(food_id):
		return 0

	var base_reward = GameData.foods[food_id]["price"]
	var income_level = min(GameData.upgrades["income"], 5)
	var bonus = 1 + (income_level * 0.08)
	var reward = int(base_reward * bonus)

	print(
		"Food:", food_id,
		" Base:", base_reward,
		" IncomeLv:", income_level,
		" Final:", reward
	)

	return reward

func consume_food_item(food_item):
	if food_item.is_source:
		return

	food_item.dragging = false
	food_item.queue_free()
