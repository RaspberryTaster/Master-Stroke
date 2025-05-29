extends Node2D

@onready var _lines: Node2D = $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport/LinesLayer/Line2D
@onready var _draw_canvas: Control = %Canvas
@onready var _subviewport_container := $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/CanvasBackground/SubViewportContainer
@onready var _subviewport := $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport

@onready var reference_viewport_container = $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/ReferenceBackground/SubViewportContainer
@onready var reference_subviewport = $CanvasLayer/VBoxContainer/VBoxContainer/Panel/HBoxContainer/ReferenceBackground/SubViewportContainer/SubViewport

@onready var outcome_subviewport_container = $Outcome/SubViewportContainer
@onready var outcome_subviewport = $Outcome/SubViewportContainer/SubViewport

var mouse_inside_viewport = false

var _current_line: Line2D = null

var percent = 0

func _process(delta):
	%PercentLabel.text = str(percent) + "%"
	
func _ready():
	TimeManager.on_start.connect(clear_lines)
	TimeManager.on_start.connect(start_session)
	TimeManager.timeout.connect(_on_compare_button_button_up)
	
	start_session()
		
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
	
func set_size(rect,_size):
	var ratio = rect.size.x / rect.size.y
	var width_bigger = rect.size.x > rect.size.y
	if width_bigger:
		rect.size.x = _size
		rect.size.y = rect.size.x * ratio
	else:
		rect.size.y = _size
		rect.size.x = rect.size.y * ratio	
func start_session():
	var rect = %ReferenceTexture
	set_size(rect,300)
	 
	_subviewport_container.size.x = rect.size.x
	_subviewport_container.size.y = rect.size.y
	
	reference_viewport_container.size.x = rect.size.x
	reference_viewport_container.size.y = rect.size.y	
	
	_lines.points.clear()
	
	center(reference_viewport_container)		
	center(_subviewport_container)	
	center(rect)
	
	
		
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
	$CanvasLayer.visible = false
	$Outcome.visible = true
	
	await get_tree().process_frame
	await get_tree().process_frame  # Double buffer
	
	var viewport_texture = _subviewport.get_texture()
	var image = viewport_texture.get_image()
	var b = reference_subviewport.get_texture().get_image()
	

	
	var shader = %OutcomeReferenceTexture.material
	
	shader.set_shader_parameter("image_a", viewport_texture)
	shader.set_shader_parameter("image_b", reference_subviewport.get_texture())

	outcome_subviewport.size.x = reference_subviewport.size.x
	outcome_subviewport.size.y = reference_subviewport.size.y
	
	outcome_subviewport_container.size.x = reference_subviewport.size.x
	outcome_subviewport_container.size.y =reference_subviewport.size.y	

	center(outcome_subviewport_container)
		
	await RenderingServer.frame_post_draw
		
	var shader_texture = outcome_subviewport.get_texture()
	var shader_image = shader_texture.get_image()
	shader_image.save_png("res://ooga.png")
	percent = calculate_accuracy(shader_image)
	

func _on_button_button_up():
	$Outcome.visible = false
	$CanvasLayer.visible = true
	TimeManager.next()
	clear_lines()


func _on_button_2_button_up():
	%SettingPanel.visible = !%SettingPanel.visible


func _on_restart_button_button_up():
	$Outcome.visible = false
	$CanvasLayer.visible = true
	TimeManager.next()
	clear_lines()
