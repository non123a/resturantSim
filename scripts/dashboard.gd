extends Control

func _on_play_button_pressed():
	AudioManager.play_ui_click()
	if GameData.campaign_failed:
		show_start_menu()
		return

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
	var debt_ratio = 0.0
	if DebtManager.debt_amount > 0:
		debt_ratio = float(DebtManager.debt_progress) / float(DebtManager.debt_amount)

	$DebtPanel/WeekLabel.text = "Week " + str(DebtManager.current_week)
	$DebtPanel/DebtProgressBar.max_value = 1.0
	$DebtPanel/DebtProgressBar.value = clamp(debt_ratio, 0.0, 1.0)
	$DebtPanel/DebtProgressLabel.text = str(DebtManager.debt_progress) + " / " + str(DebtManager.debt_amount)
	$DebtPanel/DaysRemainingLabel.text = "Days Remaining: " + str(DebtManager.days_remaining)


func _on_debt_changed():
	update_debt_ui()


func show_start_menu():
	var failed_campaign = GameData.campaign_failed
	$StartMenu/ContinueButton.visible = not failed_campaign
	$StartMenu/ContinueButton.disabled = failed_campaign
	$StartMenu/NewGameButton.offset_top = 365.0 if not failed_campaign else 305.0
	$StartMenu/NewGameButton.offset_bottom = 425.0 if not failed_campaign else 365.0
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
	get_tree().change_scene_to_file("res://scenes/intro/Intro.tscn")

func _on_upgrade_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/upgrade.tscn")


func _on_unlock_new_food_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/foodunlock.tscn")
