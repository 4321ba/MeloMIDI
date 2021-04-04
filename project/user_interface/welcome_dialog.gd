extends AcceptDialog

onready var open_file_dialog: FileDialog = $"../open_file_dialog"

func _ready():
	call_deferred("popup_centered")

func _on_welcome_dialog_confirmed():
	open_file_dialog.popup_centered()
