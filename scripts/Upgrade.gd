extends Control

const MAX_UPGRADE_LEVEL = 5
const UPGRADE_COSTS = [75, 150, 275, 450, 650]

func _ready():
	AudioManager.play_bgm_dashboard()
	update_ui()

func update_ui():
	$CoinLabel.text = "Coins: " + str(GameData.coins)
	
	$CookLevelLabel.text = "Cook Lv: " + str(GameData.upgrades["cook_speed"]) + "/" + str(MAX_UPGRADE_LEVEL)
	$IncomeLevelLabel.text = "Income Lv: " + str(GameData.upgrades["income"]) + "/" + str(MAX_UPGRADE_LEVEL)
	$CookUpgradeButton.disabled = GameData.upgrades["cook_speed"] >= MAX_UPGRADE_LEVEL
	$IncomeUpgradeButton.disabled = GameData.upgrades["income"] >= MAX_UPGRADE_LEVEL

func get_upgrade_cost(upgrade_id):
	var level = GameData.upgrades[upgrade_id]
	if level >= MAX_UPGRADE_LEVEL:
		return 0

	return UPGRADE_COSTS[level]


func _on_cook_upgrade_button_pressed():
	AudioManager.play_ui_click()

	if GameData.upgrades["cook_speed"] >= MAX_UPGRADE_LEVEL:
		return

	var cost = get_upgrade_cost("cook_speed")
	
	if GameData.coins >= cost:
		GameData.coins -= cost
		GameData.upgrades["cook_speed"] += 1
		GameData.save_game()
	
	update_ui()


func _on_income_upgrade_button_pressed():
	AudioManager.play_ui_click()

	if GameData.upgrades["income"] >= MAX_UPGRADE_LEVEL:
		return

	var cost = get_upgrade_cost("income")
	
	if GameData.coins >= cost:
		GameData.coins -= cost
		GameData.upgrades["income"] += 1
		GameData.save_game()
	
	update_ui()


func _on_back_button_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")
