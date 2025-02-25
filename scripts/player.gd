extends Node3D

# Player properties
@export var team: int
@export var throw_power_min: float = 10.0
@export var throw_power_max: float = 30.0
@export var camera_sensitivity: float = 0.003

# Throw angle control
@export var min_pitch: float = -30.0  # Degrees
@export var max_pitch: float = 30.0   # Degrees

# State
var is_aiming: bool = false
var throw_power: float = 0.0
var current_baton = null

# Nodes
@onready var camera = $Camera3D
@onready var aim_indicator = $AimIndicator
@onready var power_bar = $UI/PowerBar

# References
var game_manager = null

func _ready():
	# Get game manager reference
	game_manager = get_node("/root/main_game/game_manager")
	
	# Initialize aiming UI elements
	if aim_indicator:
		aim_indicator.visible = false
	
	# Initialize power bar
	if power_bar:
		power_bar.min_value = 0
		power_bar.max_value = 1
		power_bar.value = 0
		power_bar.visible = false

func _input(event):
	# Handle camera rotation with mouse when aiming
	if is_aiming and event is InputEventMouseMotion:
		# Rotate the camera horizontally (yaw)
		rotate_y(-event.relative.x * camera_sensitivity)
		
		# Rotate the camera vertically (pitch) with clamping
		var pitch = camera.rotation.x - event.relative.y * camera_sensitivity
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		camera.rotation.x = pitch
	
	# Start aiming with right mouse button
	if event.is_action_pressed("right_click"):
		start_aiming()
	elif event.is_action_released("right_click"):
		cancel_aiming()
	
	# Charge throw power with left mouse button
	if is_aiming and event.is_action_pressed("left_click"):
		start_charging()
	elif is_aiming and event.is_action_released("left_click"):
		execute_throw()

func _process(delta):
	# Update power bar while charging
	if is_aiming and Input.is_action_pressed("left_click"):
		throw_power = min(throw_power + delta, 1.0)
		if power_bar:
			power_bar.value = throw_power
	
	# Update aim indicator
	if is_aiming and aim_indicator:
		update_aim_indicator()

func start_aiming():
	# Check if it's this player's turn
	if game_manager and game_manager.current_team != team:
		print("Not your turn!")
		return
	
	# Get a baton to throw
	current_baton = get_next_baton()
	if not current_baton:
		print("No batons left to throw!")
		return
	
	is_aiming = true
	
	# Show aiming UI
	if aim_indicator:
		aim_indicator.visible = true
	
	# Show the baton in hand position
	position_baton_for_aiming()
	
	print("Started aiming")

func cancel_aiming():
	is_aiming = false
	throw_power = 0.0
	
	# Hide aiming UI
	if aim_indicator:
		aim_indicator.visible = false
	if power_bar:
		power_bar.visible = false
		power_bar.value = 0
	
	# Reset baton position if needed
	if current_baton:
		current_baton.reset()
		current_baton = null
	
	print("Canceled aiming")

func start_charging():
	throw_power = 0.0
	
	# Show power bar
	if power_bar:
		power_bar.visible = true
	
	print("Started charging throw")

func execute_throw():
	if not is_aiming or not current_baton:
		return
	
	# Calculate throw direction from camera
	var throw_direction = -camera.global_transform.basis.z
	
	# Calculate actual throw power based on charge
	var actual_power = lerp(throw_power_min, throw_power_max, throw_power)
	
	# Execute the throw
	current_baton.prepare_throw(camera.global_transform.origin, throw_direction)
	current_baton.execute_throw(actual_power / throw_power_max)
	
	print("Executed throw with power: ", actual_power)
	
	# Reset state
	is_aiming = false
	throw_power = 0.0
	current_baton = null
	
	# Hide UI elements
	if aim_indicator:
		aim_indicator.visible = false
	if power_bar:
		power_bar.visible = false
		power_bar.value = 0
	
	# Signal to game manager that the throw is complete
	# This will typically be handled by the baton itself

func get_next_baton():
	# Get the next available baton from the game manager
	# This is a placeholder - you'll need to implement the actual logic
	return null  # Replace with actual baton retrieval

func position_baton_for_aiming():
	# Position the baton in the player's hand for aiming
	if current_baton:
		# Position slightly in front of the camera
		var hand_position = camera.global_transform.origin + camera.global_transform.basis.z * -0.5
		current_baton.global_transform.origin = hand_position
		
		# Orient the baton along the throw direction
		current_baton.look_at(hand_position - camera.global_transform.basis.z)

func update_aim_indicator():
	# Update the aim indicator to show throw trajectory
	# This would typically use a line or series of points to show the predicted path
	pass
