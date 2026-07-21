extends TextureButton


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("TextureButton got mouse")
