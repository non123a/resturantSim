extends Node

var foods = {

	# =========================
	# DISPLAY FOOD
	# =========================
	
	"donut": {
		"type": "display",
		"steps": [],
		"cook_time": 1.0,
		"price": 8
	},
	
	"apple_pie": {
		"type": "display",
		"steps": [],
		"cook_time": 1.5,
		"price": 10
	},
	
	"jelly": {
		"type": "display",
		"steps": [],
		"cook_time": 1.0,
		"price": 7
	},
	
	"fruitcake": {
		"type": "display",
		"steps": [],
		"cook_time": 1.5,
		"price": 11
	},


	# =========================
	# MICROWAVE FOOD
	# =========================
	
	"hotdog": {
		"type": "microwave",
		"steps": ["microwave"],
		"cook_time": 2.0,
		"price": 12
	},
	
	"meatball": {
		"type": "microwave",
		"steps": ["microwave"],
		"cook_time": 2.5,
		"price": 13
	},
	
	"bun": {
		"type": "microwave",
		"steps": ["microwave"],
		"cook_time": 1.5,
		"price": 9
	},


	# =========================
	# STOVE FOOD
	# =========================
	
	"steak": {
		"type": "stove",
		"steps": ["stove"],
		"cook_time": 4.0,
		"price": 15
	},
	
	"bacon": {
		"type": "stove",
		"steps": ["stove"],
		"cook_time": 2.5,
		"price": 12
	},


	# =========================
	# MULTI-STEP FOOD
	# =========================
	
	"burger": {
		"type": "multi",
		"steps": ["prep", "stove"],
		"cook_time": 5.0,
		"price": 25
	},
	
	"burrito": {
		"type": "multi",
		"steps": ["prep", "stove"],
		"cook_time": 5.5,
		"price": 22
	}
}
