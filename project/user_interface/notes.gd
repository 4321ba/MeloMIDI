extends Node2D

const NOTE_SCENE: PackedScene = preload("res://user_interface/note.tscn")

var note_being_added: Note

onready var graph_area: Node2D = $".."

func _on_graph_spacer_gui_input(event: InputEvent):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if event.pressed:
			var note_position = event.position / graph_area.scale
			var note: Note = NOTE_SCENE.instance()
			note.note = 127 - int(note_position.y) / spectrum_analyzer.subdivision
			note.begin = note_position.x
			note.fix_point_for_resize(false, event.global_position.x)
			note_being_added = note
			add_child(note)
		else:
			note_being_added = null
	elif event is InputEventMouseMotion and note_being_added:
		note_being_added.resize(event.global_position.x)

func remove_notes():
	for note in get_children():
		note.queue_free()

func add_notes(notes: PoolIntArray):
	for i in notes.size() / 4:
		var note: Note = NOTE_SCENE.instance()
		note.begin = notes[4 * i]
		note.length = notes[4 * i + 1] - note.begin
		note.note = notes[4 * i + 2]
		note.velocity = notes[4 * i + 3]
		add_child(note)
