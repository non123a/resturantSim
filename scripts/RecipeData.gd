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
