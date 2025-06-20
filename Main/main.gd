extends Node2D

@onready var _lines: Node2D = $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport/LinesLayer/Line2D
@onready var _draw_canvas: Control = %Canvas
@onready var _subviewport_container := $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/CanvasBackground/SubViewportContainer
@onready var _subviewport := $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport

@onready var reference_viewport_container = $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/ReferenceBackground/SubViewportContainer
@onready var reference_subviewport = $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/ReferenceBackground/SubViewportContainer/SubViewport

@onready var outcome_subviewport_container = $Outcome/CenterContainer/SubViewportContainer
@onready var outcome_subviewport = $Outcome/CenterContainer/SubViewportContainer/SubViewport

var vary_reference_resolution = false
var vary_canvas_resolution = false


var mouse_inside_viewport = false

var _current_line: Line2D = null

var percent = 0

var path = ""
var image_files = []
var current_image_index = 0


func _process(delta):
	%PercentLabel.text = str(percent) + "%"
	
func _ready():
	ImageNavigationManager.setImage.connect(on_set_image)
	TimeManager.on_start.connect(clear_lines)
	TimeManager.timeout.connect(_on_compare_button_button_up)
	SaveLoadManager.load_path()
	
func update_images():
	if %ReferenceTexture.texture == null:
		return
	var width = %ReferenceTexture.texture.get_width()
	var height = %ReferenceTexture.texture.get_height()
	var rng = RandomNumberGenerator.new()
	var size = get_size(Vector2(width,height), 300 if  not	vary_reference_resolution else rng.randi_range(300,600))	

	reference_viewport_container.size = Vector2(size.x, size.y)
	
	center(reference_viewport_container)
	
	%ReferenceTexture.size =  Vector2(size.x, size.y)
	
	_subviewport_container.size = get_size(Vector2(width,height), 300 if 	not vary_canvas_resolution else rng.randi_range(300,600))	
	center(_subviewport_container)		
	
func on_set_image(image_texture):
	if image_texture == null:
		return
	%ReferenceTexture.texture = image_texture
	update_images()

func clear_lines():
	print_debug("CLEAR LINES")
	var children =  _lines.get_children()
	for child in children:
		child.queue_free()

func is_background_pixel(c: Color, threshold: float = 0.95) -> bool:
	return c.a < 0.1 or (c.r > threshold and c.g > threshold and c.b > threshold)

func calculate_accuracy(shader_result: Image) -> float:
	var shader = %OutcomeReferenceTexture.material as Material
	var width = shader_result.get_width()
	var height = shader_result.get_height()
	var total_pixels = width * height
	var reference_area = 0
	var player_area = 0
	var overlap_area = 0
	var correct_color = shader.get_shader_parameter("correct_color")
	var user_color = shader.get_shader_parameter("user_color")
	var reference_color = shader.get_shader_parameter("reference_color")
	for y in height:
		for x in width:
			var color = shader_result.get_pixel(x, y)
			
			if color.is_equal_approx(Color.WHITE):
				continue

			elif color.is_equal_approx(user_color):
				player_area += 1

			elif color.is_equal_approx(reference_color):
				reference_area += 1
			else:
				overlap_area += 1
				reference_area += 1
				player_area += 1
				
	if reference_area == 0: return 0.0
	var accuracy = (overlap_area / float(reference_area)) * 100
	var overdraw_penalty = (player_area - overlap_area) * 0.1
		
	return clamp(accuracy, 0.0, 100.0)
			
func colors_are_similar(c1: Color, c2: Color, threshold: float = 0.05) -> bool:
	var dr = abs(c1.r - c2.r)
	var dg = abs(c1.g - c2.g)
	var db = abs(c1.b - c2.b)
	var da = abs(c1.a - c2.a)
	return (dr + dg + db + da) <= threshold

func _input(event):
	if event is InputEventMouseMotion:
		var pos = event.position - _subviewport_container.global_position
	
		if Input.is_action_pressed("stylus"):
			if _current_line != null:
				_current_line.add_point(pos)
			else:
				stroke(pos)
		else:
			_current_line = null
		
				
func stroke(_pos):
	_current_line = Line2D.new()
	_current_line.default_color = Color.BLACK
	_current_line.width = 3
	_lines.add_child(_current_line)
	_current_line.add_point(_pos)
	_current_line.add_point(_pos + Vector2.ONE)	
		
func _is_within_canvas(pos: Vector2) -> bool:
	# Use the SubViewport size itself to check bounds
	return Rect2(Vector2.ZERO, _subviewport.size).has_point(pos)


func _on_start_button_button_up():
	%StopButton.visible = true
	%StartButton.visible = false
	TimeManager.start()


func _on_next_button_button_up():
	TimeManager.next()


func _on_sub_viewport_container_mouse_entered():
	mouse_inside_viewport = true



func center(rect):
	rect.anchor_left = 0.5
	rect.anchor_right = 0.5
	rect.anchor_top = 0.5
	rect.anchor_bottom = 0.5
	
	var texture_size = rect.size
	rect.offset_left = -texture_size.x / 2
	rect.offset_right = texture_size.x / 2
	rect.offset_top = -texture_size.y / 2
	rect.offset_bottom = texture_size.y / 2

func get_size(size :Vector2, limit : float):
	var width = limit
	var height = (size.y / size.x) * limit
	
	if height > limit:
		height = limit
		width = (size.x/size.y) * limit
	
	return Vector2(width,height)

		
func _on_sub_viewport_container_mouse_exited():
	mouse_inside_viewport = false


func _on_export_button_button_up():
		# Assuming 'sub_viewport' is your SubViewport node
	var viewport_texture = _subviewport.get_texture()
	var image = viewport_texture.get_image()

	# Save to file (optional)
	image.save_png("res://output_image.png")


func _on_stop_button_button_up():
	%StopButton.visible = false
	%StartButton.visible = true
	TimeManager.stop()

func get_new_size(size,_limit):
	pass
	
func _on_compare_button_button_up():
	
	await get_tree().process_frame
	await get_tree().process_frame  # Double buffer
	
	var viewport_texture = _subviewport.get_texture()
	
	var shader = %OutcomeReferenceTexture.material
	
	shader.set_shader_parameter("image_a", viewport_texture)
	shader.set_shader_parameter("image_b", reference_subviewport.get_texture())
	
	outcome_subviewport.size = get_size(reference_subviewport.size,500)

	#center(outcome_subviewport_container)
		
	await RenderingServer.frame_post_draw
	
	$CanvasLayer.visible = false
	$Outcome.visible = true	
	var shader_texture = outcome_subviewport.get_texture()
	var shader_image = shader_texture.get_image()
	shader_image.save_png("res://ooga.png")
	percent = calculate_accuracy(shader_image)
	
func save():
	SaveLoadManager.save_dict["vary_reference_scale"] = vary_reference_resolution 
	SaveLoadManager.save_dict["vary_canvas_scale"] = vary_canvas_resolution	
	SaveLoadManager.save_dict["interval_time"] = TimeManager.interval_time
	
func load():
	if SaveLoadManager.save_dict.has("image_path"):
		%FileDialog.current_dir = SaveLoadManager.save_dict["image_path"]
	
	if SaveLoadManager.save_dict.has("vary_reference_scale"):
		%ReferenceScaleToggle.button_pressed = SaveLoadManager.save_dict["vary_reference_scale"]
		vary_reference_resolution = SaveLoadManager.save_dict["vary_reference_scale"]
	if SaveLoadManager.save_dict.has("vary_canvas_scale"):
		%CanvasScaleToggle.button_pressed = SaveLoadManager.save_dict["vary_canvas_scale"]		
		vary_canvas_resolution = SaveLoadManager.save_dict["vary_canvas_scale"]		
	if SaveLoadManager.save_dict.has("interval_time"):
		TimeManager.interval_time = SaveLoadManager.save_dict["interval_time"]		
		%TimeLineEdit.placeholder_text = 	str(SaveLoadManager.save_dict["interval_time"])		
func _on_button_button_up():
	$Outcome.visible = false
	$CanvasLayer.visible = true

	ImageNavigationManager.next_image()
	TimeManager.next()
	clear_lines()


func _on_button_2_button_up():
	%SettingPanel.visible = !%SettingPanel.visible


func _on_restart_button_button_up():
	$Outcome.visible = false
	$CanvasLayer.visible = true
	TimeManager.next()
	clear_lines()


func _on_find_references_button_up():
	%FileDialog.visible = true



func _on_file_dialog_dir_selected(dir):
	ImageNavigationManager._on_file_dialog_dir_selected(dir)


func _on_file_dialog_canceled():
		%SettingPanel.visible = false


func _on_file_dialog_confirmed():
		%SettingPanel.visible = false



func _on_tree_exited():
	ImageNavigationManager.save()


func _on_canvas_resolution_toggle_toggled(toggled_on):
	vary_canvas_resolution = toggled_on
	update_images()
	SaveLoadManager.save_dict["vary_canvas_scale"] = vary_canvas_resolution	

func _on_reference_resolution_toggle_toggled(toggled_on):
	vary_reference_resolution = toggled_on
	update_images()
	SaveLoadManager.save_dict["vary_reference_scale"] = vary_reference_resolution 
