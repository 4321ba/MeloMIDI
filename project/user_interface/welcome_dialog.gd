extends AcceptDialog

onready var open_wave_file_dialog: FileDialog = $"../open_wave_file_dialog"

func _ready():
	call_deferred("popup_centered")

func _on_welcome_dialog_confirmed():
	open_wave_file_dialog.popup_centered()
