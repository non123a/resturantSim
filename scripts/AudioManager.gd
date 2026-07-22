extends Node

var dashboard_bgm = preload("res://assets/chimengAsset/sound/dashboard_sound.mp3")
var gameplay_bgm = preload("res://assets/chimengAsset/sound/gameplay_sound.mp3")

var ui_click_sound = preload("res://assets/chimengAsset/sound/sound1.ogg")
var drag_sound = preload("res://assets/chimengAsset/sound/sound2.ogg")
var drop_sound = preload("res://assets/chimengAsset/sound/sound3.ogg")
var error_sound = preload("res://assets/chimengAsset/sound/false.ogg")

var bgm_volume_db = -10.0
var sfx_volume_db = -4.0

var bgm_player: AudioStreamPlayer
var current_bgm = ""


func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.volume_db = bgm_volume_db
	add_child(bgm_player)


func play_ui_click():
	play_sfx(ui_click_sound)


func play_drag():
	play_sfx(drag_sound)


func play_drop():
	play_sfx(drop_sound)


func play_error():
	play_sfx(error_sound)


func play_bgm_dashboard():
	play_bgm("dashboard", dashboard_bgm)


func play_bgm_gameplay():
	play_bgm("gameplay", gameplay_bgm)


func stop_bgm():
	current_bgm = ""
	bgm_player.stop()


func play_bgm(bgm_id, stream):
	if current_bgm == bgm_id and bgm_player.playing:
		return

	current_bgm = bgm_id
	stream.loop = true
	bgm_player.stop()
	bgm_player.stream = stream
	bgm_player.volume_db = bgm_volume_db
	bgm_player.play()


func play_sfx(stream):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = sfx_volume_db
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
