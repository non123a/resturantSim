extends Node
func _ready():
	save_existed_on_start = FileAccess.file_exists("user://savegame.save")
	load_game()
	normalize_unlocked_foods()
	normalize_upgrades()
	
var coins = 0
var best_coins = 0
var upgrades = {
	"cook_speed": 0,
	"income": 0
}
var last_loaded_save_data = {}
var save_existed_on_start = false
var start_menu_seen = false
var force_intro_after_reset = false
var campaign_failed = false
var lifetime_coins_earned = 0
var customers_served = 0
var highest_combo = 0

var foods = {
	"donut": {
		"type": "display",
		"steps": [],
		"cook_time": 1.0,
		"price": 6,
		"display_name": "Donut",
		"wait_time": 8.0,
		"icon": preload("res://assets/chimengAsset/donut/donut.png")
	},
	"jelly": {
		"type": "prep",
		"steps": ["prep"],
		"cook_time": 1.0,
		"price": 10,
		"display_name": "Jelly",
		"wait_time": 10.0,
		"icon": preload("res://assets/chimengAsset/jelly/jelly plate.png")
	},
	"apple_pie": {
		"type": "display",
		"steps": [],
		"cook_time": 1.5,
		"price": 10,
		"display_name": "Apple Pie",
		"wait_time": 10.0,
		"icon": preload("res://assets/chimengAsset/pie/apple pie.png")
	},
	"fruitcake": {
		"type": "display",
		"steps": [],
		"cook_time": 1.5,
		"price": 11,
		"display_name": "Fruitcake",
		"wait_time": 10.0,
		"icon": preload("res://assets/chimengAsset/pie/apple pie.png")
	},
	"hotdog": {
		"type": "microwave",
		"steps": ["microwave"],
		"cook_time": 2.0,
		"price": 12,
		"display_name": "Hotdog",
		"wait_time": 12.0,
		"icon": preload("res://assets/chimengAsset/hotdog bread/hotdogs.png")
	},
	"meatball": {
		"type": "microwave",
		"steps": ["microwave"],
		"cook_time": 2.5,
		"price": 13,
		"display_name": "Meatball",
		"wait_time": 12.0,
		"icon": preload("res://assets/chimengAsset/meatball/meatballs.png")
	},
	"bun": {
		"type": "microwave",
		"steps": ["microwave"],
		"cook_time": 1.5,
		"price": 9,
		"display_name": "Bun",
		"wait_time": 12.0,
		"icon": preload("res://assets/chimengAsset/hotdog bread/breads.png")
	},
	"steak": {
		"type": "stove",
		"steps": ["stove"],
		"cook_time": 4.0,
		"price": 18,
		"display_name": "Steak",
		"wait_time": 18.0,
		"icon": preload("res://assets/chimengAsset/steak/steaks.png")
	},
	"bacon": {
		"type": "stove",
		"steps": ["stove"],
		"cook_time": 2.5,
		"price": 14,
		"display_name": "Bacon",
		"wait_time": 18.0,
		"icon": preload("res://assets/chimengAsset/steak/beefs.png")
	},
	"burger": {
		"type": "multi",
		"steps": ["prep", "stove"],
		"cook_time": 6.0,
		"price": 30,
		"display_name": "Burger",
		"wait_time": 28.0,
		"icon": preload("res://assets/chimengAsset/hamburger/hamburgers.png")
	},
	"burrito": {
		"type": "multi",
		"steps": ["prep"],
		"cook_time": 5.5,
		"price": 24,
		"display_name": "Burrito",
		"wait_time": 26.0,
		"icon": preload("res://assets/chimengAsset/burrito/burrito.png")
	}
}

var food_progression_order = [
	"donut",
	"steak",
	"jelly",
	"burrito",
	"burger"
]

var food_progression = {
	"donut": {
		"unlock_cost": 0,
		"implemented": true,
		"start_unlocked": true
	},
	"steak": {
		"unlock_cost": 0,
		"implemented": true,
		"start_unlocked": true
	},
	"burger": {
		"unlock_cost": 500,
		"implemented": true,
		"start_unlocked": false
	},
	"burrito": {
		"unlock_cost": 300,
		"implemented": true,
		"start_unlocked": false
	},
	"jelly": {
		"unlock_cost": 120,
		"implemented": true,
		"start_unlocked": false
	}
}

var unlocked_foods = [
	"steak",
	"donut"
]

func get_available_order_foods():
	var available_foods = []

	for food in unlocked_foods:
		if is_food_implemented(food) and foods.has(food):
			available_foods.append(food)

	return available_foods

func get_random_order_food():
	var available_foods = get_available_order_foods()

	if available_foods.is_empty():
		return ""

	return available_foods.pick_random()

func get_progression_food_ids():
	return food_progression_order

func get_food_display_name(food_id):
	return foods[food_id]["display_name"]

func get_food_unlock_cost(food_id):
	return food_progression[food_id]["unlock_cost"]

func is_food_implemented(food_id):
	return food_progression.has(food_id) and food_progression[food_id]["implemented"]

func is_food_unlocked(food_id):
	return unlocked_foods.has(food_id)

func can_unlock_food(food_id):
	return food_progression.has(food_id) and not is_food_unlocked(food_id)

func unlock_food(food_id):
	if not can_unlock_food(food_id):
		return false

	var cost = get_food_unlock_cost(food_id)
	if coins < cost:
		return false

	coins -= cost
	unlocked_foods.append(food_id)
	save_game()
	return true

func normalize_unlocked_foods():
	var normalized_foods = []

	for food in food_progression_order:
		if food_progression[food]["start_unlocked"] or unlocked_foods.has(food):
			normalized_foods.append(food)

	unlocked_foods = normalized_foods

func normalize_upgrades():
	upgrades["cook_speed"] = clamp(upgrades.get("cook_speed", 0), 0, 5)
	upgrades["income"] = clamp(upgrades.get("income", 0), 0, 5)


func should_show_start_menu():
	return campaign_failed or (save_existed_on_start and not start_menu_seen)


func has_save_file():
	return FileAccess.file_exists("user://savegame.save")


func should_play_intro():
	return force_intro_after_reset or not has_save_file()


func mark_intro_played():
	force_intro_after_reset = false


func mark_start_menu_seen():
	start_menu_seen = true


func add_lifetime_coins(amount):
	lifetime_coins_earned += max(amount, 0)


func record_customer_served(combo_count):
	customers_served += 1
	highest_combo = max(highest_combo, combo_count)


func mark_campaign_failed():
	campaign_failed = true
	save_game()


func get_campaign_stats_text():
	var weeks_survived = max(DebtManager.current_week - 1, 0)
	var days_played = max(DebtManager.current_day - 1, 0)
	return \
		"Weeks Survived: " + str(weeks_survived) + \
		"\nDays Played: " + str(days_played) + \
		"\nLifetime Coins Earned: " + str(lifetime_coins_earned) + \
		"\nBest Run Coins: " + str(best_coins) + \
		"\nCustomers Served: " + str(customers_served) + \
		"\nHighest Combo: " + str(highest_combo)


func reset_progress():
	coins = 0
	best_coins = 0
	upgrades = {
		"cook_speed": 0,
		"income": 0
	}
	campaign_failed = false
	lifetime_coins_earned = 0
	customers_served = 0
	highest_combo = 0
	unlocked_foods = []
	normalize_unlocked_foods()
	normalize_upgrades()

	var debt_manager = get_node_or_null("/root/DebtManager")
	if debt_manager != null:
		debt_manager.reset_progress()

	start_menu_seen = true
	force_intro_after_reset = true
	save_existed_on_start = true
	save_game()


func save_game():
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)

	var data = {
		"coins": coins,
		"best_coins": best_coins,
		"upgrades": upgrades,
		"unlocked_foods": unlocked_foods,
		"campaign_failed": campaign_failed,
		"lifetime_coins_earned": lifetime_coins_earned,
		"customers_served": customers_served,
		"highest_combo": highest_combo
	}

	var debt_manager = get_node_or_null("/root/DebtManager")
	if debt_manager != null:
		data.merge(debt_manager.get_save_data(), true)

	last_loaded_save_data = data
	file.store_var(data)


func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		last_loaded_save_data = {}
		return

	var file = FileAccess.open("user://savegame.save", FileAccess.READ)

	var data = file.get_var()
	if typeof(data) != TYPE_DICTIONARY:
		data = {}
	last_loaded_save_data = data

	coins = data.get("coins", coins)
	best_coins = data.get("best_coins", best_coins)
	upgrades = data.get("upgrades", upgrades)
	unlocked_foods = data.get("unlocked_foods", unlocked_foods)
	campaign_failed = data.get("campaign_failed", campaign_failed)
	lifetime_coins_earned = data.get("lifetime_coins_earned", lifetime_coins_earned)
	customers_served = data.get("customers_served", customers_served)
	highest_combo = data.get("highest_combo", highest_combo)
	normalize_unlocked_foods()
	normalize_upgrades()
