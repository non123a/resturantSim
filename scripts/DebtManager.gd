extends Node

signal debt_changed

var week_length = 3
var starting_debt = 300
var debt_increase_per_week = 75

var current_day = 1
var current_week = 1
var debt_amount = 300
var days_remaining = 3
var debt_progress = 0
var debt_failed = false


func _ready():
	load_save_data(GameData.last_loaded_save_data)


func complete_run(run_income):
	if debt_failed:
		return {
			"debt_failed": true,
			"week_advanced": false
		}

	debt_progress += max(run_income, 0)
	days_remaining -= 1
	current_day += 1

	var result = {
		"debt_failed": false,
		"week_advanced": false
	}

	if days_remaining <= 0:
		if debt_progress >= debt_amount:
			advance_week()
			result["week_advanced"] = true
		else:
			debt_failed = true
			result["debt_failed"] = true

	debt_changed.emit()
	return result


func advance_week():
	current_week += 1
	debt_amount += debt_increase_per_week
	debt_progress = 0
	days_remaining = week_length


func get_save_data():
	return {
		"current_day": current_day,
		"current_week": current_week,
		"debt_amount": debt_amount,
		"days_remaining": days_remaining,
		"debt_progress": debt_progress
	}


func load_save_data(data):
	current_day = int(data.get("current_day", 1))
	current_week = int(data.get("current_week", 1))
	debt_amount = int(data.get("debt_amount", starting_debt))
	days_remaining = int(data.get("days_remaining", week_length))
	debt_progress = int(data.get("debt_progress", 0))
	debt_failed = false
	normalize_debt_state()
	debt_changed.emit()


func reset_progress():
	current_day = 1
	current_week = 1
	debt_amount = starting_debt
	days_remaining = week_length
	debt_progress = 0
	debt_failed = false
	debt_changed.emit()


func normalize_debt_state():
	current_day = max(current_day, 1)
	current_week = max(current_week, 1)
	debt_amount = max(debt_amount, starting_debt)
	days_remaining = clamp(days_remaining, 0, week_length)
	debt_progress = max(debt_progress, 0)


func get_debt_summary_text():
	return \
		"Day: " + str(current_day) + \
		"\nWeek: " + str(current_week) + \
		"\nDebt Target: " + str(debt_amount) + \
		"\nDebt Progress: " + str(debt_progress) + "/" + str(debt_amount) + \
		"\nDays Remaining: " + str(days_remaining)
