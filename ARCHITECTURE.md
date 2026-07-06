# UnderseaRestaurant Architecture

## Folder Structure

- `project.godot` - Godot 4.5 project config. Starts at the dashboard scene and registers autoloads.
- `scenes/main/` - main gameplay scene.
- `scenes/customer/` - customer scene.
- `scenes/dashboard/` - dashboard, upgrades, and food unlock menus.
- `scenes/food/` - reusable draggable ingredient scene and its active ingredient script.
- `scripts/` - gameplay managers, data singletons, station logic, customer logic, menus, and older/unused scripts.
- `assets/chimengAsset/` - food and character art assets.
- `assets/sprites/` - customer sprite frames and character base assets.
- `professional_kitchen/` - kitchen tile/background art used by the main scene.

## Important Scenes

- `scenes/dashboard/dashboard.tscn` - startup scene. Shows play, upgrade, unlock-food buttons, best run, and total coins.
- `scenes/dashboard/upgrade.tscn` - upgrade menu for cook speed and income upgrades.
- `scenes/dashboard/foodunlock.tscn` - unlock menu for bread and steak. Burger and pie buttons exist but are stubs.
- `scenes/main/main.tscn` - main gameplay. Contains HUD, timer, end panel, old cook buttons, food panel buttons, station nodes, drop areas, kitchen map, and ingredient shelf.
- `scenes/customer/Customer.tscn` - moving/waiting customer with order label, patience bar, collision, and animated sprite.
- `scenes/food/Ingredient.tscn` - reusable `Area2D` ingredient with sprite, collision, exported ingredient fields, and drag behavior.

## Main Scripts

- `scripts/GameManager.gd` - central gameplay controller for spawning customers, round timer, coins, combo, old fish/shrimp cooking, ready-food inventory, serving, station signal hookup, and current steak drag/drop recipe.
- `scripts/customer.gd` - customer movement, patience, order selection, click/tap serving, happy/angry exit, and stop behavior on game over.
- `scenes/food/ingredient.gd` - active draggable ingredient behavior used by `Ingredient.tscn`. Tracks mouse drag, calls `current_scene.try_drop_ingredient(self)`, and resets if not accepted.
- `scripts/Station.gd` - generic timed processing station. Emits `process_finished(job)` when a `FoodJob` completes a station step.
- `scripts/FoodJob.gd` - data model for multi-step food work: food id, steps, current step, completion, station waiting, and processing state.
- `scripts/FoodData.gd` - autoload food catalog with type, station steps, cook time, and price.
- `scripts/GameData.gd` - autoload persistent state: coins, best coins, upgrades, unlocked foods, save/load.
- `scripts/Upgrade.gd` - upgrade menu logic. Spends coins and increments `cook_speed` or `income`.
- `scripts/foodunlock.gd` - food unlock menu logic. Unlocks bread and steak if the player has enough coins.
- `scripts/dashboard.gd` - dashboard navigation and record display.
- `scripts/Food.gd` - simple standalone cooking timer script; currently not referenced by scenes.
- `scripts/Ingredient.gd` - older ingredient drag script; not the script used by `scenes/food/Ingredient.tscn`.
- `scripts/stove_area.gd` - older/partial stove area helper attached to `Stations/StoveArea`, but current drop handling is in `GameManager.try_drop_ingredient`.

## Game Flow

1. Godot starts at `scenes/dashboard/dashboard.tscn`.
2. `GameData` autoload loads saved coins, upgrades, best run, and unlocked foods.
3. Dashboard shows best run and total coins.
4. Play changes to `scenes/main/main.tscn`.
5. `GameManager._ready()` connects station finish signals, spawns two customers, updates coin UI, and hides locked food buttons.
6. Customers walk in, choose a random order from `GameData.unlocked_foods`, then wait while patience drains.
7. Player creates food through either old button cooking or current ingredient drag/drop.
8. Completed food names are stored in `ready_foods`.
9. Clicking/tapping a customer calls `try_serve_customer`; matching ready food pays coins, increments combo, removes the customer, and spawns a replacement.
10. When the 60-second timer ends, gameplay stops, customers stop moving, best run is updated, and `GameData.save_game()` persists progress.

## Singletons / Autoloads

- `GameData` -> `res://scripts/GameData.gd`
  - Loads on startup.
  - Persists coins, best coins, upgrades, and unlocked foods to `user://savegame.save`.
- `FoodData` -> `res://scripts/FoodData.gd`
  - In-memory food catalog.
  - Used for customer rewards in `try_serve_customer`.

## Current Drag-And-Drop System

- Drag source: `scenes/food/Ingredient.tscn` using `scenes/food/ingredient.gd`.
- Active ingredients in `main.tscn`: `RawSteak`, `Vegetables`, hidden `CookedSteak`, hidden `BeefPlate`.
- On left mouse press, the ingredient starts following the mouse.
- On release, it awaits `get_tree().current_scene.try_drop_ingredient(self)`.
- If accepted, `GameManager` positions/hides/shows ingredients according to the recipe.
- If rejected, the ingredient snaps back to its original start position.
- Drop checks currently use `Area2D.overlaps_area(ingredient)` against `Stations/StoveArea` and `Stations/PrepArea`.

## Current Cooking Pipeline

There are three overlapping cooking models:

- Old button cooking:
  - `CookFishButton` and `CookShrimpButton` call `start_cooking("fish"|"shrimp")`.
  - `GameManager._process()` advances a timer and sets `food_ready = true`.
  - `serve_food(customer)` can serve this model, but current customer click handling uses `try_serve_customer`, so this path is largely legacy.
- Station/job pipeline:
  - `FoodData` defines food steps such as `["microwave"]`, `["stove"]`, or `["prep", "stove"]`.
  - `FoodJob` and `Station` support timed multi-step processing.
  - `GameManager` connects `PrepStation`, `StoveStation`, and `MicrowaveStation` to `_on_station_finished`.
  - No current script creates jobs or calls `Station.start_process`, so this pipeline is present but not fully wired.
- New drag steak pipeline:
  - Drag `raw_steak` to `Stations/StoveArea`.
  - After 2 seconds, raw steak hides and `CookedSteak` appears at the drop position.
  - Drag `cooked_steak` plus `vegetables` to `Stations/PrepArea`.
  - After 1 second, both inputs hide and `BeefPlate` appears.
  - This pipeline currently creates visible plated food but does not add `"steak"` or `"beef_plate"` into `ready_foods`, so it is not yet connected to serving/rewards.

## Customer / Order System

- Customers are spawned by `GameManager.spawn_customer()` at one of three positions.
- Each customer gets `game_manager = self` and chooses `order = GameData.unlocked_foods.pick_random()`.
- Order text is shown in `OrderLabel`.
- Customers walk to their target, then wait while patience decreases.
- On timeout, they call `leave_angry()` and free themselves.
- On click/tap, customer calls `game_manager.try_serve_customer(self)`.
- `try_serve_customer` checks whether `customer.order` exists in `ready_foods`.
- Correct service removes one ready food, calls `customer.serve()`, applies income upgrade multiplier, adds coins, increments combo, removes customer from the list, and spawns a new customer.
- Wrong click with some ready food resets combo; click with no ready food only prints "Food not ready".

## Upgrade / Economy System

- `GameData.coins` starts at 500 unless a save exists.
- `run_coins` tracks current round earnings only.
- `GameData.best_coins` stores best round earnings.
- Income upgrade:
  - Bought in `upgrade.tscn`.
  - Cost is `50 + income_level * 25`.
  - Serving reward multiplier is `1 + income_level * 0.1`.
- Cook speed upgrade:
  - Bought in `upgrade.tscn`.
  - Cost is `50 + cook_speed_level * 25`.
  - Old fish/shrimp cooking uses `timer = max(0.5, cook_time - cook_speed * 0.3)`.
  - It does not currently affect the drag steak timers or `Station.gd` timers.
- Food unlocks:
  - Bread costs 100 coins.
  - Steak costs 200 coins.
  - Unlocks are saved and used by customer order selection.
  - Main scene shows/hides Bread and Steak food-panel buttons based on unlock state.

## Signals Between Objects

- Scene button signals:
  - Dashboard buttons navigate to play, upgrade, and food unlock scenes.
  - Upgrade buttons buy upgrades or go back.
  - Food unlock buttons unlock bread/steak or go back.
  - Main old cook buttons call fish/shrimp cooking handlers.
  - Main end panel buttons restart or return to dashboard.
- Customer input:
  - `Customer._input_event` handles mouse/touch press and calls `GameManager.try_serve_customer`.
- Ingredient input:
  - `Ingredient._input_event` handles drag start/drop and calls `GameManager.try_drop_ingredient`.
- Station processing:
  - `Station.gd` defines `process_finished(job)`.
  - `GameManager._ready()` connects all three station nodes to `_on_station_finished`.
- Wired but missing handlers:
  - `main.tscn` connects food-panel buttons to `_on_burger_button_pressed`, `_on_bread_button_pressed`, `_on_steak_button_pressed`, and `_on_donut_button_pressed`, but those methods are not present in `GameManager.gd`.
  - `main.tscn` connects station area `input_event` signals to `_on_stove_area_input_event`, `_on_microwave_area_input_event`, `_on_prep_area_input_event`, and `_on_display_area_input_event`, but those methods are not present in `GameManager.gd`.

## Old Click Interaction Still In Use

- Dashboard, upgrade, food unlock, restart, and back buttons.
- Old `CookFishButton` / `CookShrimpButton` cooking.
- Customer click/tap serving through `Customer._input_event`.
- Food-panel buttons in `main.tscn` are still connected as click interactions, but their handlers are missing from `GameManager.gd`.
- Station area `input_event` click handlers are connected in `main.tscn`, but their handlers are missing from `GameManager.gd`.

## New Drag Interaction Already In Use

- `RawSteak`, `Vegetables`, `CookedSteak`, and `BeefPlate` instances use `scenes/food/Ingredient.tscn`.
- `raw_steak` can be dragged to `Stations/StoveArea` to produce `cooked_steak`.
- `vegetables` and `cooked_steak` can be dragged to `Stations/PrepArea` to produce `beef_plate`.
- Drag rejection/reset is handled in `scenes/food/ingredient.gd`.
- The new drag system is not yet integrated with `FoodData`, `FoodJob`, `Station.start_process`, customer serving, or rewards.
