extends Area2D

func ingredient_dropped(ingredient):

	if ingredient.get_ingredient_name() != "raw_steak":
		return

	print("Cooking Raw Steak...")

	ingredient.visible = false

	await get_tree().create_timer(2.0).timeout

	get_parent().get_parent().get_node("CanvasLayer2/IngredientPanel/CookedSteak").visible = true
