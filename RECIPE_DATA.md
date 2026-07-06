# RecipeData Notes

Recipes live in `scripts/RecipeData.gd`.

Each recipe dictionary has:

- `recipe_id` - unique id for logs/debugging.
- `station` - drop station id, such as `stove` or `prep`.
- `inputs` - ingredient ids required at that station.
- `duration` - processing time in seconds.
- `output_ingredient` - ingredient id to show when processing completes.
- `output_food_id` - served food id. Use `""` for intermediate ingredients.

To add a new recipe:

1. Add a recipe dictionary to `RecipeData.recipes`.
2. Add the matching draggable ingredient/output nodes to `main.tscn`.
3. Add those ingredient ids to `GameManager.get_ingredient_node()`.
4. When the finished meal is playable, add its food id to `GameData.implemented_foods`.

Example:

```gdscript
{
	"recipe_id": "cook_steak",
	"station": "stove",
	"inputs": ["raw_steak"],
	"duration": 2.0,
	"output_ingredient": "cooked_steak",
	"output_food_id": ""
}
```
