extends LineEdit


func _on_gui_input(event):
	# Check if the event is a key press
	if event is  InputEventKey:
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		# Get the unicode character of the pressed key
		var unicode = OS.get_keycode_string(keycode)
		# Check if the unicode character is a digit or a valid input
		#print(unicode)
		if unicode == "Backspace" or unicode == "Enter":
			pass
		elif unicode.is_valid_int() or unicode.is_valid_float():
			# Allow digits to be entered
			pass
		elif unicode == ',':
			# Accept comma as a decimal separator
			pass
		elif unicode == '.':
			# Accept dot as a decimal separator
			pass
		else:
			accept_event()


func _on_text_changed(new_text):
	TimeManager.interval_time = new_text.to_float()
	#TimeManager.timer.wait_time = TimeManager.interval_time
