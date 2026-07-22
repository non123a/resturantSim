extends Control

@onready var food_buttons = {
	"donut": $DonutButton,
	"steak": $SteakButton,
	"burger": $BurgerButton,
	"burrito": $BurritoButton,
	"jelly": $JellyButton
}

@onready var food_button_visuals = {
	"donut": {
		"button": $DonutButton,
		"locked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/unlock donut.png"),
		"unlocked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/donut.png")
	},
	"steak": {
		"button": $SteakButton,
		"locked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/unlock steak.png"),
		"unlocked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/steak.png")
	},
	"burger": {
		"button": $BurgerButton,
		"locked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/unlock hamburger.png"),
		"unlocked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/hamburger.png")
	},
	"burrito": {
		"button": $BurritoButton,
		"locked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/unlock burrito.png"),
		"unlocked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/burrito.png")
	},
	"jelly": {
		"button": $JellyButton,
		"locked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/unlock jelly.png"),
		"unlocked_texture": preload("res://assets/chimengAsset/icon2/unlocking food/jelly.png")
	}
}

func _ready():
	AudioManager.play_bgm_dashboard()
	update_ui()

func update_ui():
	update_coin_label()

	for food_id in GameData.get_progression_food_ids():
		update_food_button(food_id)

func update_coin_label():
	$CoinLabel.text = "Coins: " + str(GameData.coins)

func update_food_button(food_id):
	var button = food_buttons[food_id]
	var visuals = food_button_visuals[food_id]
	var is_unlocked = GameData.is_food_unlocked(food_id)

	button.texture_normal = visuals["unlocked_texture"] if is_unlocked else visuals["locked_texture"]
	button.disabled = is_unlocked

func try_unlock_food(food_id):
	if GameData.is_food_unlocked(food_id):
		AudioManager.play_error()
		return

	if not GameData.unlock_food(food_id):
		print("Not enough coins")
		AudioManager.play_error()
		return

	update_coin_label()
	update_food_button(food_id)

func _on_donut_button_pressed() -> void:
	AudioManager.play_ui_click()
	try_unlock_food("donut")

func _on_steak_button_pressed() -> void:
	AudioManager.play_ui_click()
	try_unlock_food("steak")

func _on_burger_button_pressed() -> void:
	AudioManager.play_ui_click()
	try_unlock_food("burger")

func _on_burrito_button_pressed() -> void:
	AudioManager.play_ui_click()
	try_unlock_food("burrito")

func _on_jelly_button_pressed() -> void:
	AudioManager.play_ui_click()
	try_unlock_food("jelly")

func _on_back_button_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")
