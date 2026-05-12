extends Control


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")


func _ready():
	$RecordLabel.text = "Best: " + str(GameData.best_coins)

func _on_upgrade_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/Upgrade.tscn")
