
extends Node

@export var image_files_default = []
@export var image_files = []
var exclusive_image_files = []
var path = ""
@export var exclusive := false
@export var random := false
const SAVE_GAME_PATH := "user://save.save"
var current_image_index = 0

signal setImage(filePath:String)

func filter_files(_files:Array):
	var output = []
	for n in range(_files.size()):
		var file = _files[n]
		if(file.ends_with(".png")) or (file.ends_with(".jpg")) or (file.ends_with(".jpeg")):
			output.append(file)
	return output
	
func list_files_in_directory(_path):
	var output = []
	var dir = DirAccess.open(_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if not file_name.begins_with("."):
					print("Found file: " + file_name)
					output.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return output
# Called when the node enters the scene tree for the first time.
func _ready():
	#image_files_default = filter_files(list_files_in_directory("res://Refrences/Random_01/"))	
	pass

func save_path():
	SaveLoadManager.save_path()


func save():
	SaveLoadManager.save_dict["image_path"] = path
	SaveLoadManager.save_dict["cur_image_index"] = current_image_index
	#SaveLoadManager.save_dict["bar_color"] = bar_color
	
func load():
	if SaveLoadManager.save_dict.has("image_path") and SaveLoadManager.save_dict.has("cur_image_index"):		
		var images_path = SaveLoadManager.save_dict["image_path"]
		path = images_path
		var cur_image_index = SaveLoadManager.save_dict["cur_image_index"]
		current_image_index = cur_image_index
	set_path(path)

	
func dir_contents():
	var dir = DirAccess.open(path)
	if dir and path != "":
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if(file_name.ends_with(".png")) or (file_name.ends_with(".jpg")) or (file_name.ends_with(".jpeg")):
					print("Found file: " + file_name)
					var image_texture = ImageTexture.create_from_image(Image.load_from_file(path + "/" + file_name))
					image_files.append(image_texture)
					exclusive_image_files.append(image_texture)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		image_files = image_files_default.duplicate()
		exclusive_image_files = image_files.duplicate()
func next_image():

	if exclusive_image_files.size() == 0: return
	var image_file_size = exclusive_image_files.size() if exclusive else image_files.size()
	print(random)
	if(random):
		current_image_index = randi() % image_file_size  # Change current texture index to a random number within the size of image filesdex to a random number within the size of image files.
	else:	
		current_image_index += 1

#
	
	if current_image_index >= image_file_size:	
		current_image_index = 0
	
	var image = exclusive_image_files[current_image_index] if exclusive else image_files[current_image_index]
	setImage.emit(image_files[current_image_index])	
	
func previous_image():
	var image_file_size = exclusive_image_files.size() if exclusive else image_files.size()
	current_image_index -= 1
	if current_image_index < 0:	
		current_image_index = image_files.size() -1
		
	var image = exclusive_image_files[current_image_index] if exclusive else image_files[current_image_index]
	setImage.emit(image_files[current_image_index])	

func set_path(dir):
	#print(dir)
	#current_image_index = 0
	image_files = []
	exclusive_image_files = []
	path = dir
	dir_contents()
	if(image_files.size() == 0):
		print("No images")
	else:
		#save_path()
		setImage.emit(image_files[current_image_index])	
		#set_image()		
		
func _on_file_dialog_dir_selected(dir):
	#print(dir)
	current_image_index = 0
	image_files = []
	exclusive_image_files = []
	path = dir
	dir_contents()
	if(image_files.size() == 0):
		print("No images")
	else:
		save_path()
		setImage.emit(image_files[current_image_index])	

	
func reset(_exclusive = false, _random = false):
	print(random)
	current_image_index = 0
	setImage.emit(image_files[current_image_index])	
	exclusive = _exclusive
	random = _random
