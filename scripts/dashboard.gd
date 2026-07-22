extends Control

func _on_play_button_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _ready():
	AudioManager.play_bgm_dashboard()
	$NewGameConfirm.get_ok_button().text = "Confirm"
	$NewGameConfirm.get_cancel_button().text = "Cancel"
	if not DebtManager.debt_changed.is_connected(_on_debt_changed):
		DebtManager.debt_changed.connect(_on_debt_changed)
	update_dashboard_ui()

	if GameData.should_show_start_menu():
		show_start_menu()


func update_dashboard_ui():
	$RecordLabel.text = \
		"Best Run: " + str(GameData.best_coins) + \
		"\nTotal Coins: " + str(GameData.coins)
	update_debt_ui()


func update_debt_ui():
	$DebtPanel/WeekLabel.text = "Week " + str(DebtManager.current_week)
	$DebtPanel/DebtProgressBar.max_value = max(DebtManager.debt_amount, 1)
	$DebtPanel/DebtProgressBar.value = min(DebtManager.debt_progress, DebtManager.debt_amount)
	$DebtPanel/DebtProgressLabel.text = str(DebtManager.debt_progress) + " / " + str(DebtManager.debt_amount)
	$DebtPanel/DaysRemainingLabel.text = "Days Remaining: " + str(DebtManager.days_remaining)


func _on_debt_changed():
	update_debt_ui()


func show_start_menu():
	$StartMenu.visible = true


func close_start_menu():
	GameData.mark_start_menu_seen()
	$StartMenu.visible = false


func _on_continue_button_pressed():
	AudioManager.play_ui_click()
	close_start_menu()


func _on_new_game_button_pressed():
	AudioManager.play_ui_click()
	$NewGameConfirm.popup_centered()


func _on_new_game_confirm_confirmed():
	AudioManager.play_ui_click()
	GameData.reset_progress()
	get_tree().reload_current_scene()

#func _on_upgrade_button_pressed():
	#get_tree().change_scene_to_file("res://scenes/dashboard/upgrade.tscn")

func _on_upgrade_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/upgrade.tscn")


func _on_unlock_new_food_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/foodunlock.tscn")
