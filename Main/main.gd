extends Node2D

@onready var _lines: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport/LinesLayer/Line2D
@onready var _draw_canvas: Control = %Canvas
@onready var _subviewport_container := $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer
@onready var _subviewport := $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport

var mouse_inside_viewport = false

var _current_line: Line2D = null


func _ready():
	TimeManager.on_start.connect(clear_lines)
	
func clear_lines():
	print_debug("CLEAR LINES")
	var children =  _lines.get_children()
	for child in children:
		child.queue_free()

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
	_current_line.width = 5
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


func _on_sub_viewport_container_mouse_exited():
	mouse_inside_viewport = false
