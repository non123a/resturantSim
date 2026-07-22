extends Control

func _on_play_button_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _ready():
	AudioManager.play_bgm_dashboard()
	$RecordLabel.text = \
		"Best Run: " + str(GameData.best_coins) + \
		"\nTotal Coins: " + str(GameData.coins) + \
		"\n\n" + DebtManager.get_debt_summary_text()

#func _on_upgrade_button_pressed():
	#get_tree().change_scene_to_file("res://scenes/dashboard/upgrade.tscn")

func _on_upgrade_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/upgrade.tscn")


func _on_unlock_new_food_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/foodunlock.tscn")
