extends RigidBody3D

# Baton properties
@export var team: int
@export var throw_power: float = 20.0
@export var spin_power: float = 5.0

# State tracking
var is_thrown: bool = false
var is_held: bool = false
var throw_cooldown: float = 0.0

# References
var game_manager = null
var throw_direction = Vector3.ZERO
var throw_origin = Vector3.ZERO

func _ready():
	# Connect to needed signals
	body_entered.connect(_on_body_entered)
	
	# Find the game manager node
	game_manager = get_node("/root/main_game/game_manager")
	
	# Add to the "batons" group for collision detection
	add_to_group("batons")
	
	# Set physics properties
	gravity_scale = 1.0
	continuous_cd = true  # Enable continuous collision detection for fast-moving objects

func _physics_process(delta):
	# Handle throw cooldown
	if throw_cooldown > 0:
		throw_cooldown -= delta
	
	# If the baton has been thrown and is now at rest
	if is_thrown and is_at_rest():
		is_thrown = false
		_on_throw_complete()

func is_at_rest() -> bool:
	# Check if baton has stopped moving
	return linear_velocity.length() < 0.1 and angular_velocity.length() < 0.1

func prepare_throw(origin: Vector3, direction: Vector3):
	# Set up the baton for throwing
	is_held = true
	is_thrown = false
	throw_direction = direction.normalized()
	throw_origin = origin
	
	# Position the baton at the throw origin
	global_transform.origin = throw_origin
	
	# Reset physics state
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Orient the baton for throwing (assuming Z-axis is forward)
	look_at(throw_origin + throw_direction)

func execute_throw(power_multiplier: float = 1.0, spin_multiplier: float = 1.0):
	if not is_held or throw_cooldown > 0:
		return
	
	is_held = false
	is_thrown = true
	throw_cooldown = 1.0  # 1 second cooldown
	
	# Calculate force based on throw direction and power
	var force = throw_direction * throw_power * power_multiplier
	
	# Apply force at the center of mass
	apply_central_impulse(force)
	
	# Apply some spin (torque) for realism
	var spin_axis = throw_direction.cross(Vector3.UP).normalized()
	if spin_axis.length() < 0.1:  # If throw direction is nearly vertical
		spin_axis = Vector3.RIGHT  # Use an arbitrary horizontal axis
	
	apply_torque_impulse(spin_axis * spin_power * spin_multiplier)
	
	# Notify game manager
	if game_manager:
		game_manager.throw_baton(self, throw_direction, force.length())

func _on_body_entered(body):
	# Handle collision with other objects
	if not is_thrown:
		return
	
	if body.is_in_group("kubbs") or body.is_in_group("king"):
		print("Baton hit: ", body.name)

func _on_throw_complete():
	print("Throw completed, baton at rest")
	
	# Notify game manager if needed
	# The actual hit detection is handled by the kubb/king scripts

func reset():
	# Reset the baton for a new throw
	is_thrown = false
	is_held = false
	throw_cooldown = 0
	
	# Reset physics state
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Reset rotation
	rotation = Vector3.ZERO
