extends Node2D

@onready var _lines: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport/LinesLayer/Line2D
@onready var _draw_canvas: Control = %Canvas
@onready var _subviewport_container := $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer
@onready var _subviewport := $CanvasLayer/VBoxContainer/HBoxContainer/CanvasBackground/SubViewportContainer/SubViewport

var _pressed: bool = false
var _current_line: Line2D = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_pressed = event.pressed
			
			if _pressed:
				var local_mouse_pos =  _subviewport.get_mouse_position()
				if _is_within_canvas(local_mouse_pos):
					_current_line = Line2D.new()
					_current_line.default_color = Color.BLUE
					_current_line.width = 4
					_lines.add_child(_current_line)
					_current_line.add_point(local_mouse_pos)
					_current_line.add_point(local_mouse_pos + Vector2.ONE)

	elif event is InputEventMouseMotion and _pressed and _current_line:
		var local_mouse_pos = _subviewport.get_mouse_position()
		_current_line.add_point(local_mouse_pos)


func _is_within_canvas(pos: Vector2) -> bool:
	# Use the SubViewport size itself to check bounds
	return Rect2(Vector2.ZERO, _subviewport.size).has_point(pos)


func _on_start_button_button_up():
	TimeManager.start()


func _on_next_button_button_up():
	TimeManager.next()
