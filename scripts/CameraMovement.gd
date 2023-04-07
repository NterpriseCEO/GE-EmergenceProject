extends KinematicBody

var velocity = Vector3(0, 0, 0)
const SPEED = 20
var y = 0

var cam_x_rotation = Vector3.UP

var isFollowCam = false
var randomVehicle

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Checks if the users mouse is moving and sets the rotation of the camera
	if event is InputEventMouseMotion:
		cam_x_rotation.x -= event.relative.y*0.2
		cam_x_rotation.x = clamp(cam_x_rotation.x, -90, 0)
		cam_x_rotation.y -= event.relative.x*0.2

	# Checks if the user is pressing V to toggle between the free camera and the
	# follow camera
	if event is InputEventKey:
		if Input.is_action_pressed("camera_change"):
			isFollowCam = !isFollowCam
			randomVehicle = Globals.vehicles[randi() % Globals.vehicles.size()]

	# Determines which direction the camera will move
	var move_dir = Vector3(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("q") - Input.get_action_strength("e"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized().rotated(Vector3.UP, rotation.y)
	
	velocity.x = move_dir.x
	velocity.y = move_dir.y
	velocity.z = move_dir.z
	# Moves the camera
	velocity = move_and_slide((velocity*translation.y))

	# clamps the y value between 2 and 100
	translation.y = clamp(translation.y, 2, 70)
	rotation_degrees = cam_x_rotation

func _process(delta):
	if randomVehicle and isFollowCam:
		translation = randomVehicle.translation+Vector3(0, 0.5, 0)
		var rot = randomVehicle.rotation
		rotation_degrees = Vector3(rad2deg(rot.x),rad2deg(rot.y)-180,0)
#		-Vector3(0, 180, 0)
#		print(randomVehicle.rotation)

func _physics_process(delta):
	pass
