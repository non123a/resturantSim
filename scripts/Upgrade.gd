extends Control

func _ready():
	update_ui()

func update_ui():
	$CoinLabel.text = "Coins: " + str(GameData.coins)
	
	$CookLevelLabel.text = "Cook Lv: " + str(GameData.upgrades["cook_speed"])
	$IncomeLevelLabel.text = "Income Lv: " + str(GameData.upgrades["income"])


func _on_cook_upgrade_button_pressed():
	var cost = 50 + (GameData.upgrades["cook_speed"] * 25)
	
	if GameData.coins >= cost:
		GameData.coins -= cost
		GameData.upgrades["cook_speed"] += 1
	
	update_ui()


func _on_income_upgrade_button_pressed():
	#var cost = 50
	var cost = 50 + (GameData.upgrades["income"] * 25)
	
	if GameData.coins >= cost:
		GameData.coins -= cost
		GameData.upgrades["income"] += 1
	
	update_ui()


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")
