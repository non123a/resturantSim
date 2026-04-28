extends Node2D

var coins = 0
var customer_scene = preload("res://scenes/customer/Customer.tscn")

var customers = []


var food_ready = false
var cooking = false
var cook_time = 2.0
var timer = 0.0

#func _ready():
	#spawn_customer()
func _ready():
	for i in range(2):   # start with 2 customers
		spawn_customer()
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

func _process(delta):
	if cooking:
		timer -= delta
		if timer <= 0:
			cooking = false
			food_ready = true
			print("Food Ready!")

#func start_cooking():
	#if not cooking and not food_ready:
		#cooking = true
		#timer = cook_time
		#print("Cooking...")
func start_cooking():
	if not cooking and not food_ready:
		cooking = true
		timer = cook_time
		
		$CanvasLayer/CookButton.text = "Cooking..."
	if timer <= 0:
		cooking = false
		food_ready = true
		
		$CanvasLayer/CookButton.text = "SERVE!"


func serve_food(customer):
	if food_ready and customer != null:
		customer.serve()
		add_coins(10)
		
		print("Served!")
		
		food_ready = false
		$CanvasLayer/CookButton.text = "Cook"
		
		customers.erase(customer)
		
		spawn_customer()

func add_coins(amount):
	coins += amount
	print("Coins:", coins)


func _on_cook_button_pressed():
	start_cooking()
