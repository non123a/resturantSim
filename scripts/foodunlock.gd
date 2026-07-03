extends Control


# Called when the node enters the scene tree for the first time.
func _ready():

	if "bread" in GameData.unlocked_foods:
		$BreadButton.disabled = true
	if "steak" in GameData.unlocked_foods:
		$SteakButton.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bread_button_pressed() -> void:

	if "bread" in GameData.unlocked_foods:
		print("Bread already unlocked")
		return

	var cost = 100

	if GameData.coins < cost:
		print("Not enough coins")
		return

	GameData.coins -= cost
	GameData.unlocked_foods.append("bread")
	GameData.save_game()
	$BreadButton.disabled = true

	print("Bread unlocked!")

func _on_steak_button_pressed() -> void:

	if "steak" in GameData.unlocked_foods:
		print("Steak already unlocked")
		return

	var cost = 200

	if GameData.coins < cost:
		print("Not enough coins")
		return

	GameData.coins -= cost
	GameData.unlocked_foods.append("steak")
	GameData.save_game()

	$SteakButton.disabled = true

	print("Steak unlocked!")

func _on_burger_button_pressed() -> void:
	pass # Replace with function body.


func _on_pie_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")
