extends CharacterBody3D

var speed = 5
var jump_height = 250
var fall_speed = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sens = 0.3
var camera_anglev = 0

@onready var camera = $Camera3D
@onready var synchronizer = $MultiplayerSynchronizer

func _ready():
	synchronizer.set_multiplayer_authority(str(name).to_int())
	camera.current = synchronizer.is_multiplayer_authority()

func _physics_process(delta):
	if synchronizer.is_multiplayer_authority():
		var direction = Vector3.ZERO
		if Input.is_action_pressed("forward"): direction -= global_transform.basis.z
		elif Input.is_action_pressed("backward"): direction += global_transform.basis.z
		if Input.is_action_pressed("left"): direction -= global_transform.basis.x
		elif Input.is_action_pressed("right"): direction += global_transform.basis.x
		
		velocity = direction * speed
		if not is_on_floor(): velocity.y -= fall_speed
		if Input.is_action_pressed("jump") and is_on_floor(): velocity.y = jump_height
		move_and_slide()
		synchronizer.position = global_position



func _input(event):
	if event.is_action_pressed("ui_end"):
		synchronizer.visible = not synchronizer.visible
	if synchronizer.is_multiplayer_authority():
		if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(deg_to_rad(-event.relative.x*mouse_sens))
			synchronizer.y_rotation = rotation.y
			var changev=-event.relative.y*mouse_sens
			if camera_anglev+changev>-50 and camera_anglev+changev<50:
				camera_anglev+=changev
				$Camera3D.rotate_x(deg_to_rad(changev))

