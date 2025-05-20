extends Node2D

@onready var _lines: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport/LinesLayer/Line2D
@onready var _draw_canvas: Control = %Canvas
@onready var _subviewport_container := $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer
@onready var _subviewport := $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport
@onready var reference_viewport_container = $CanvasLayer/VBoxContainer/HBoxContainer/ReferenceBackground/SubViewportContainer
@onready var reference_subviewport = $CanvasLayer/VBoxContainer/HBoxContainer/ReferenceBackground/SubViewportContainer/SubViewport
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

		
func compare_images_percentage(img1: Image, img2: Image) -> float:
	var target_width = min(img1.get_width(), img2.get_width())
	var target_height = min(img1.get_height(), img2.get_height())

	# Resize img1 to match img2
	var resized_img1 = img1.duplicate()
	resized_img1.resize(target_width, target_height, Image.INTERPOLATE_LANCZOS)

	var total_considered_pixels = 0
	var matching_pixels = 0

	for y in range(target_height):
		for x in range(target_width):
			var color1 = resized_img1.get_pixel(x, y)
			var color2 = img2.get_pixel(x, y)

			# Skip white or transparent pixels (e.g. background)
			if is_background_pixel(color1) and is_background_pixel(color2):
				continue

			total_considered_pixels += 1

			if colors_are_similar(color1, color2):
				matching_pixels += 1

	if total_considered_pixels == 0:
		return 0.0  # Avoid divide-by-zero

	return float(matching_pixels) / total_considered_pixels * 100.0

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
	TimeManager.stop()


func _on_compare_button_button_up():
	var viewport_texture = _subviewport.get_texture()
	var image = viewport_texture.get_image()
	var b = reference_subviewport.get_texture().get_image()
	
	#image.save_png("res://drawn_image.png")
	#b.save_png("res://reference_image.png")
	percent = compare_images_percentage(image,b)
	print_debug(percent)
	$CanvasLayer.visible = false
	$Outcome.visible = true
	var shader = %OutcomeReferenceTexture.material
	shader.set_shader_parameter("image_a", viewport_texture)
	shader.set_shader_parameter("image_b", reference_subviewport.get_texture())
	%OutcomeReferenceTexture.texture = reference_subviewport.get_texture()

	set_size(%OutcomeReferenceTexture,400)
	center(%OutcomeReferenceTexture)
	
func _on_button_button_up():
	$Outcome.visible = false
	$CanvasLayer.visible = true
	TimeManager.next()
	clear_lines()
