extends Node2D

var coins = 0
var customer_scene = preload("res://scenes/customer/Customer.tscn")

var customers = []

var food_types = ["fish", "shrimp"]
var current_food = ""

var round_time = 60.0
var time_left = 60.0
var game_active = true


var combo = 0
var combo_timer = 0.0
var combo_window = 10.0  # seconds to keep combo alive

var food_ready = false
var cooking = false
var cook_time = 2.0
var timer = 0.0


func _ready():
	for i in range(2):   # start with 2 customers
		spawn_customer()
	$CanvasLayer/CoinLabel.text = "Coins: 0"
	
var spawn_positions = [
	Vector2(200, 500),
	Vector2(360, 500),
	Vector2(520, 500)
]

func spawn_customer():
	var c = customer_scene.instantiate()
	add_child(c)
	
	var index = customers.size() % spawn_positions.size()
	c.position = Vector2(spawn_positions[index].x, 1400)
	c.target_position = spawn_positions[index]
	
	c.game_manager = self
	
	customers.append(c)


func reset_combo():
	combo = 0
	combo_timer = 0
	update_combo_ui()
	print("Combo reset")

#func end_game():
	#game_active = false
	#
	#print("Game Over!")
	#print("Final Coins:", coins)
	#
	## stop everything
	#cooking = false
	#food_ready = false
	#
	## disable buttons
	#$CanvasLayer/CookFishButton.disabled = true
	#$CanvasLayer/CookShrimpButton.disabled = true

func _process(delta):
	if game_active:
		time_left -= delta
		
		if time_left <= 0:
			end_game()
		
		$CanvasLayer/TimerLabel.text = "Time: " + str(int(time_left))
	if combo > 0 and not cooking:
		combo_timer -= delta
		
		if combo_timer <= 0:
			reset_combo()
	if cooking:
		timer -= delta
		
		var progress = (1 - (timer / cook_time)) * 100
		$CanvasLayer/CookingBar.value = progress
		
		print("Progress:", progress)   # debug
		
		if timer <= 0:
			cooking = false
			food_ready = true
			$CanvasLayer/CookingBar.visible = false
			
			print("Food Ready!")
			
			$CanvasLayer/CookFishButton.text = "Fish"
			$CanvasLayer/CookShrimpButton.text = "Shrimp"

		
func start_cooking(food_type):
	$CanvasLayer/CookingBar.visible = true
	$CanvasLayer/CookingBar.value = 0
	if not game_active:
		return
	if not cooking and not food_ready:
		cooking = true
		timer = cook_time
		
		current_food = food_type
		
		print("Cooking:", current_food)
		
		$CanvasLayer/CookFishButton.text = "Cooking fish..."
		$CanvasLayer/CookShrimpButton.text = "Cooking shrimp..."

func serve_food(customer):
	if not game_active:
		return
	if not food_ready or customer == null:
		return
	
	if current_food == customer.order:
		customer.serve()
		
		combo += 1
		combo_timer = combo_window
		update_combo_ui()
		
		var reward = 10 + (combo * 2)
		add_coins(reward)
		
		print("Correct! Combo:", combo, "Reward:", reward)
	else:
		print("Wrong order!")
		customer.leave_angry()
		reset_combo()
	
	# Reset cooking state
	food_ready = false
	
	$CanvasLayer/CookFishButton.text = "Fish"
	$CanvasLayer/CookShrimpButton.text = "Shrimp"
	
	customers.erase(customer)
	spawn_customer()
	
	
func _on_cook_shrimp_button_pressed():
	start_cooking("shrimp")

func _on_cook_fish_button_pressed() -> void:
	start_cooking("fish")


func add_coins(amount):
	coins += amount
	print("Coins:", coins)
	
	$CanvasLayer/CoinLabel.text = "Coins: " + str(coins)


func update_combo_ui():
	if combo > 0:
		$CanvasLayer/ComboLabel.visible = true
		$CanvasLayer/ComboLabel.text = "🔥 Combo x" + str(combo)
	else:
		$CanvasLayer/ComboLabel.visible = false


func end_game():
	game_active = false
	
	print("Game Over!")
	print("Final Coins:", coins)
	
	cooking = false
	food_ready = false
	
	$CanvasLayer/CookFishButton.disabled = true
	$CanvasLayer/CookShrimpButton.disabled = true
	
	# 👇 SHOW END SCREEN
	$CanvasLayer/EndPanel.visible = true
	$CanvasLayer/EndPanel/ResultLabel.text = "Coins: " + str(coins)


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
