extends Node
func _ready():
	load_game()
	
var coins = 500
var best_coins = 0
var upgrades = {
	"cook_speed": 0,
	"income": 0
}

var unlocked_foods = [
	"steak"
	
]

var implemented_foods = [
	"steak",
	"burger"
]

func get_available_order_foods():
	var available_foods = []

	for food in unlocked_foods:
		if implemented_foods.has(food):
			available_foods.append(food)

	return available_foods

func get_random_order_food():
	var available_foods = get_available_order_foods()

	if available_foods.is_empty():
		return ""

	return available_foods.pick_random()


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
