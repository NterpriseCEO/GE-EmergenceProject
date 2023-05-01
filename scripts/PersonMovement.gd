extends BoidMovement

var total_time = 0
var amplitude = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	self.center_offset = 0.9
	self.velocity_length = 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Bounces the person up and down as if they are "walking"
	translation.y = clamp(cos(total_time) * amplitude, 0, 2)
	total_time += delta
	
	if total_time > 10000:
		total_time = 0
