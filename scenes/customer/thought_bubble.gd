extends Control

@onready var food_icon = $FoodIcon


func show_food(food_id):
	if not GameData.foods.has(food_id):
		food_icon.texture = null
		visible = false
		return

	food_icon.texture = GameData.foods[food_id]["icon"]
	visible = true
