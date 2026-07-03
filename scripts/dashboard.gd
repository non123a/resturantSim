extends Control


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _ready():
	$RecordLabel.text = \
		"Best Run: " + str(GameData.best_coins) + \
		"\nTotal Coins: " + str(GameData.coins)

#func _on_upgrade_button_pressed():
	#get_tree().change_scene_to_file("res://scenes/dashboard/upgrade.tscn")

func _on_upgrade_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dashboard/upgrade.tscn")


func _on_unlock_new_food_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dashboard/foodunlock.tscn")
