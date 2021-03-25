extends Line2D
class_name Note

var subdivision = spectrum_analyzer.subdivision
var velocity: int = 127
var note: int setget set_note
var begin: float setget set_begin
var length: float setget set_length

var resizing: bool = false
var resize_fix_point: float
var length_before_resize: float
var original_mouse_position: float

onready var container: Control = $container
onready var collision: CollisionShape2D = $area/collision

func set_note(new_note: int):
	note = new_note
	position.y = (127.5 - new_note) * subdivision

func set_begin(new_begin: float):
	begin = new_begin
	position.x = begin
	
func set_length(new_length: float):
	length = new_length if new_length >= 3 else 3
	points[1].x = length
	if container and collision:
		container.rect_size.x = length
		collision.shape.extents.x = length / 2
		collision.position.x = length / 2

func fix_point_for_resize(is_resizing_left: bool, original_position: float):
	resize_fix_point = begin + length if is_resizing_left else begin
	original_mouse_position = original_position
	length_before_resize = -length if is_resizing_left else length

func resize(current_mouse_position: float):
	var mouse_delta = (current_mouse_position - original_mouse_position) / get_global_transform().get_scale().x + length_before_resize
	if mouse_delta > 0:
		set_begin(resize_fix_point)
		set_length(mouse_delta)
	else:
		set_begin(resize_fix_point + mouse_delta)
		set_length(-mouse_delta)

func _ready():
	width = subdivision
	container.rect_position.y = -subdivision / 2.0
	container.rect_size.y = subdivision
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.extents.y = subdivision / 2.0
	collision.shape = rectangle_shape
	set_length(length)

func _on_left_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			queue_free()
		if event.button_index == BUTTON_LEFT:
			resizing = event.pressed
			if event.pressed:
				fix_point_for_resize(true, event.global_position.x)
	if event is InputEventMouseMotion and resizing:
		resize(event.global_position.x)

func _on_right_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			queue_free()
		if event.button_index == BUTTON_LEFT:
			resizing = event.pressed
			if event.pressed:
				fix_point_for_resize(false, event.global_position.x)
	if event is InputEventMouseMotion and resizing:
		resize(event.global_position.x)

func _on_middle_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			queue_free()
