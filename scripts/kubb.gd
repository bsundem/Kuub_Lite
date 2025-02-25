extends RigidBody3D

# Kubb properties
@export var team: int
@export var is_field_kubb: bool = false

# Knocked over tracking
var is_knocked: bool = false
var knocked_time: float = 0
var knock_threshold: float = 0.5  # Time in seconds that the kubb needs to be tipped to count

# Reference to game manager
var game_manager = null

func _ready():
	# Connect to needed signals
	body_entered.connect(_on_body_entered)
	
	# Find the game manager node
	game_manager = get_node("/root/main_game/game_manager")

func _physics_process(delta):
	# Check if kubb is knocked over
	if not is_knocked and _is_tipped_over():
		knocked_time += delta
		if knocked_time > knock_threshold:
			is_knocked = true
			_on_knocked_over()
	elif is_knocked and not _is_tipped_over():
		# If it was knocked but now upright (e.g. after being thrown to the field)
		is_knocked = false
		knocked_time = 0

func _is_tipped_over() -> bool:
	# Consider kubb tipped when its up vector is not mostly vertical
	# Get the up vector in global coordinates
	var up_vector = global_transform.basis.y
	# Check angle with the true up vector (0,1,0)
	return up_vector.dot(Vector3.UP) < 0.7  # If dot product is less than 0.7, angle is more than ~45 degrees

func _on_body_entered(body):
	# When hit by a baton or another kubb
	if body.is_in_group("batons"):
		print("Kubb hit by a baton!")
		
		# Tell the game manager about the hit
		if game_manager:
			game_manager.handle_kubb_hit(self)

func _on_knocked_over():
	print("Kubb knocked over!")
	
	# Change visual appearance or play sound here
	# For now, just handle the game logic
	if game_manager:
		game_manager.handle_kubb_hit(self)

func reset():
	# Reset the kubb to upright position
	knocked_time = 0
	is_knocked = false
	
	# Reset physics state
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Reset rotation to upright
	rotation = Vector3.ZERO

# Function for the game manager to get the state
func is_knocked_over() -> bool:
	return is_knocked
