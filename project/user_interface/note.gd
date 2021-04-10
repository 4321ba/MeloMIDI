extends Line2D
class_name Note

var subdivision = options.options.fft.subdivision
var velocity: int = 127 setget set_velocity
var note: int setget set_note
var begin: float setget set_begin
var length: float setget set_length

var changing_velocity: bool = false
var resizing: bool = false
var resize_fix_point: float
var length_before_resize: float
var original_mouse_position: float

onready var container: Control = $container
onready var collision: CollisionShape2D = $area/collision
onready var middle: Control = $container/middle

func set_velocity(new_velocity: int):
	velocity = clamp(new_velocity, 1, 127)
	default_color.a8 = velocity + 128
	if middle:
		middle.hint_tooltip = str(velocity)

func set_note(new_note: int):
	note = new_note
	position.y = (127.5 - new_note) * subdivision

func set_begin(new_begin: float):
	begin = new_begin
	position.x = begin
	
func set_length(new_length: float):
	length = new_length if new_length >= 3 else 3.0
	points[1].x = length
	if container and collision:
		container.rect_size.x = length
		collision.shape.b = Vector2(length, 0)

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
	var segment_shape = SegmentShape2D.new()
	collision.shape = segment_shape
	#these are from set_length and set_velocity
	#but if those are set before _ready, they can't
	#update these
	container.rect_size.x = length
	collision.shape.b = Vector2(length, 0)
	middle.hint_tooltip = str(velocity)

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
		if event.button_index == BUTTON_LEFT:
			changing_velocity = event.pressed
	if event is InputEventMouseMotion and changing_velocity:
		set_velocity(velocity - ceil(event.relative.y))
