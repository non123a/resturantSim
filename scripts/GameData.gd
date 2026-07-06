extends Node
func _ready():
	load_game()
	normalize_unlocked_foods()
	
var coins = 500
var best_coins = 0
var upgrades = {
	"cook_speed": 0,
	"income": 0
}

var food_progression_order = [
	"donut",
	"steak",
	"burger",
	"burrito",
	"jelly"
]

var food_progression = {
	"donut": {
		"display_name": "Donut",
		"unlock_cost": 0,
		"implemented": true,
		"start_unlocked": true
	},
	"steak": {
		"display_name": "Steak",
		"unlock_cost": 0,
		"implemented": true,
		"start_unlocked": true
	},
	"burger": {
		"display_name": "Burger",
		"unlock_cost": 200,
		"implemented": true,
		"start_unlocked": false
	},
	"burrito": {
		"display_name": "Burrito",
		"unlock_cost": 400,
		"implemented": true,
		"start_unlocked": false
	},
	"jelly": {
		"display_name": "Jelly",
		"unlock_cost": 650,
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
		if is_food_implemented(food):
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
	return food_progression[food_id]["display_name"]

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


func save_game():
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)

	var data = {
		"coins": coins,
		"best_coins": best_coins,
		"upgrades": upgrades,
		"unlocked_foods": unlocked_foods
	}

	file.store_var(data)


func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return

	var file = FileAccess.open("user://savegame.save", FileAccess.READ)

	var data = file.get_var()

	coins = data["coins"]
	best_coins = data["best_coins"]
	upgrades = data["upgrades"]
	unlocked_foods = data["unlocked_foods"]
	normalize_unlocked_foods()
