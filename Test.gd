extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh = self.multimesh
	for i in mesh.visible_instance_count:
		print(i)
		mesh.set_instance_transform(i, Transform(Basis(), Vector3(i * 20, 0, 0)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
