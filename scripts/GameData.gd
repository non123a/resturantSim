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
	"burger",
	"donut",
	
]


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
