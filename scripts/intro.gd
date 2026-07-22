extends Control

const DASHBOARD_SCENE = "res://scenes/dashboard/dashboard.tscn"


func _ready():
	AudioManager.stop_bgm()

	if not GameData.should_play_intro():
		get_tree().change_scene_to_file(DASHBOARD_SCENE)
		return

	if $VideoStreamPlayer.stream == null:
		push_error("Intro video could not be loaded: res://assets/chimengAsset/video/undersea-resturant.ogv")
		_finish_intro()
		return

	$VideoStreamPlayer.play()

	await get_tree().process_frame
	if not $VideoStreamPlayer.is_playing():
		push_error("Intro video failed to start: res://assets/chimengAsset/video/undersea-resturant.ogv")
		_finish_intro()


func _on_video_stream_player_finished():
	_finish_intro()


func _finish_intro():
	GameData.mark_intro_played()
	get_tree().change_scene_to_file(DASHBOARD_SCENE)
