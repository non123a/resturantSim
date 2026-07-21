extends Control

@onready var bubble_background = $BubbleBackground
@onready var food_icon = $FoodIcon


func _ready():
	var background_image = Image.create(120, 96, false, Image.FORMAT_RGBA8)
	background_image.fill(Color(1.0, 1.0, 1.0, 0.9))
	bubble_background.texture = ImageTexture.create_from_image(background_image)


func show_food(food_id):
	if not GameData.foods.has(food_id):
		food_icon.texture = null
		visible = false
		return

	food_icon.texture = GameData.foods[food_id]["icon"]
	visible = true
