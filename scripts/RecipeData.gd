extends Node

var recipes = [
	{
		"recipe_id": "cook_steak",
		"station": "stove",
		"inputs": ["raw_steak"],
		"duration": 2.0,
		"output_ingredient": "cooked_steak",
		"output_food_id": ""
	},
	{
		"recipe_id": "plate_steak",
		"station": "prep",
		"inputs": ["vegetables", "cooked_steak"],
		"duration": 1.0,
		"output_ingredient": "beef_plate",
		"output_food_id": "steak"
	},
	{
		"recipe_id": "cook_burger_beef",
		"station": "stove",
		"inputs": ["burger_raw_beef"],
		"duration": 2.0,
		"output_ingredient": "burger_beef",
		"output_food_id": ""
	},
	{
		"recipe_id": "burger_bread_plus_vegetable",
		"station": "prep",
		"inputs": ["burger_bread", "burger_vegetable"],
		"duration": 1.0,
		"output_ingredient": "burger_bread_vegetable",
		"output_food_id": ""
	},
	{
		"recipe_id": "burger_bread_plus_beef",
		"station": "prep",
		"inputs": ["burger_bread", "burger_beef"],
		"duration": 1.0,
		"output_ingredient": "burger_bread_beef",
		"output_food_id": ""
	},
	{
		"recipe_id": "burger_bread_vegetable_plus_sauce",
		"station": "prep",
		"inputs": ["burger_bread_vegetable", "burger_sauce"],
		"duration": 1.0,
		"output_ingredient": "burger_bread_vegetable_sauce",
		"output_food_id": ""
	},
	{
		"recipe_id": "burger_bread_vegetable_plus_beef",
		"station": "prep",
		"inputs": ["burger_bread_vegetable", "burger_beef"],
		"duration": 1.0,
		"output_ingredient": "burger_bread_vegetable_beef",
		"output_food_id": ""
	},
	{
		"recipe_id": "burger_bread_beef_plus_sauce",
		"station": "prep",
		"inputs": ["burger_bread_beef", "burger_sauce"],
		"duration": 1.0,
		"output_ingredient": "burger_bread_beef_sauce",
		"output_food_id": ""
	},
	{
		"recipe_id": "finish_burger_from_vegetable_sauce",
		"station": "prep",
		"inputs": ["burger_bread_vegetable_sauce", "burger_beef"],
		"duration": 1.0,
		"output_ingredient": "burger",
		"output_food_id": "burger"
	},
	{
		"recipe_id": "finish_burger_from_vegetable_beef",
		"station": "prep",
		"inputs": ["burger_bread_vegetable_beef", "burger_sauce"],
		"duration": 1.0,
		"output_ingredient": "burger",
		"output_food_id": "burger"
	},
	{
		"recipe_id": "finish_burger_from_beef_sauce",
		"station": "prep",
		"inputs": ["burger_bread_beef_sauce", "burger_vegetable"],
		"duration": 1.0,
		"output_ingredient": "burger",
		"output_food_id": "burger"
	},
	{
		"recipe_id": "burrito_meat_to_tortilla",
		"station": "prep",
		"inputs": ["burrito_meat"],
		"duration": 1.0,
		"output_ingredient": "burrito_meat_tortilla",
		"output_food_id": ""
	},
	{
		"recipe_id": "burrito_rice_to_tortilla",
		"station": "prep",
		"inputs": ["burrito_rice"],
		"duration": 1.0,
		"output_ingredient": "burrito_rice_tortilla",
		"output_food_id": ""
	},
	{
		"recipe_id": "burrito_meat_tortilla_plus_vegetable",
		"station": "prep",
		"inputs": ["burrito_meat_tortilla", "burrito_vegetable"],
		"duration": 1.0,
		"output_ingredient": "burrito_meat_tortilla_vegetable",
		"output_food_id": ""
	},
	{
		"recipe_id": "burrito_rice_tortilla_plus_vegetable",
		"station": "prep",
		"inputs": ["burrito_rice_tortilla", "burrito_vegetable"],
		"duration": 1.0,
		"output_ingredient": "burrito_rice_tortilla_vegetable",
		"output_food_id": ""
	},
	{
		"recipe_id": "burrito_meat_path_add_rice",
		"station": "prep",
		"inputs": ["burrito_meat_tortilla_vegetable", "burrito_rice"],
		"duration": 1.0,
		"output_ingredient": "burrito_beef_rice_tortilla",
		"output_food_id": ""
	},
	{
		"recipe_id": "burrito_rice_path_add_meat",
		"station": "prep",
		"inputs": ["burrito_rice_tortilla_vegetable", "burrito_meat"],
		"duration": 1.0,
		"output_ingredient": "burrito_beef_rice_tortilla",
		"output_food_id": ""
	},
	{
		"recipe_id": "wrap_burrito",
		"station": "prep",
		"inputs": ["burrito_beef_rice_tortilla"],
		"duration": 1.0,
		"output_ingredient": "burrito",
		"output_food_id": "burrito"
	}
]

func get_recipe(station, inputs):
	for recipe in recipes:
		if recipe["station"] == station and _same_inputs(recipe["inputs"], inputs):
			return recipe

	return {}

func can_accept_ingredient(station, current_inputs, ingredient_name):
	var candidate_inputs = current_inputs.duplicate()
	candidate_inputs.append(ingredient_name)

	for recipe in recipes:
		if recipe["station"] != station:
			continue

		if _inputs_fit_recipe(candidate_inputs, recipe["inputs"]):
			return true

	return false

func _same_inputs(recipe_inputs, candidate_inputs):
	return recipe_inputs.size() == candidate_inputs.size() and _inputs_fit_recipe(candidate_inputs, recipe_inputs)

func _inputs_fit_recipe(candidate_inputs, recipe_inputs):
	var remaining_inputs = recipe_inputs.duplicate()

	for input in candidate_inputs:
		var index = remaining_inputs.find(input)
		if index == -1:
			return false

		remaining_inputs.remove_at(index)

	return true
