extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	OS.set_current_screen(1)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_text("FPS " + String(Engine.get_frames_per_second()))
