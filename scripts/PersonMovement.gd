extends BoidMovement

# Called when the node enters the scene tree for the first time.
func _ready():
	self.center_offset = 0.9
	self.velocity_length = 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var oscillate : float = sin(delta * (2 * PI))-0.1

	translation.y += oscillate
