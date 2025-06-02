extends Node

var image_path = ""
var save_dict := {}
const SAVE_GAME_PATH := "user://save_data.save"

func save_path():
	var save_data = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		node.call("save")
	var json_string = JSON.stringify(save_dict)
	save_data.store_line(json_string)		
		

func load_path():


			
	var save_nodes = get_tree().get_nodes_in_group("Persist")		
	if FileAccess.file_exists(SAVE_GAME_PATH):
		var save_data = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
		var json_string = save_data.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		else:
			save_dict = json.get_data()
	#save_dict["cur_camera_zoom"] = parse_result["cur_camera_zoom"]
			print(save_dict)
	
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("load"):
			print("persistent node '%s' is missing a load function, skipped" % node.name)
			continue

		# Call the node's save function.
		node.call("load")	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_path()
		# Execute code when the game is quitting
		print("Quitting the game...")
		

func save_color_to_dict(color):
	var color_data = {
		"r": color.r,
		"g": color.g,
		"b": color.b,
		"a": color.a
	}
	return color_data
