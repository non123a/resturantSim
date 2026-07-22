extends Control

@onready var food_buttons = {
	"donut": $DonutButton,
	"steak": $SteakButton,
	"burger": $BurgerButton,
	"burrito": $BurritoButton,
	"jelly": $JellyButton
}

func _ready():
	AudioManager.play_bgm_dashboard()
	update_ui()

func update_ui():
	$CoinLabel.text = "Coins: " + str(GameData.coins)

	for food_id in GameData.get_progression_food_ids():
		var button = food_buttons[food_id]
		var display_name = GameData.get_food_display_name(food_id)

		if GameData.is_food_unlocked(food_id):
			button.text = display_name + "\nUnlocked"
			button.disabled = true
		else:
			button.text = display_name + "\nUnlock (" + str(GameData.get_food_unlock_cost(food_id)) + ")"
			button.disabled = false

func try_unlock_food(food_id):
	if GameData.is_food_unlocked(food_id):
		return

	if not GameData.unlock_food(food_id):
		print("Not enough coins")

	update_ui()

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
