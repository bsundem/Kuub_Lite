extends RigidBody3D

# Knocked over tracking
var is_knocked: bool = false
var knocked_time: float = 0
var knock_threshold: float = 0.5  # Time in seconds that the king needs to be tipped to count

# Reference to game manager
var game_manager = null

func _ready():
	# Connect to needed signals
	body_entered.connect(_on_body_entered)
	
	# Find the game manager node
	game_manager = get_node("/root/main_game/game_manager")
	
	# Add to the "king" group for easy identification
	add_to_group("king")

func _physics_process(delta):
	# Check if king is knocked over
	if not is_knocked and _is_tipped_over():
		knocked_time += delta
		if knocked_time > knock_threshold:
			is_knocked = true
			_on_knocked_over()

func _is_tipped_over() -> bool:
	# Consider king tipped when its up vector is not mostly vertical
	var up_vector = global_transform.basis.y
	return up_vector.dot(Vector3.UP) < 0.7

func _on_body_entered(body):
	# When hit by a baton
	if body.is_in_group("batons"):
		print("King hit by a baton!")
		
		# In Kubb, hitting the king before clearing all opponent's kubbs results in a loss
		# This special case needs to be handled by the game manager
		if game_manager:
			game_manager.handle_king_hit()

func _on_knocked_over():
	print("King knocked over!")
	
	# Change visual appearance or play sound here
	if game_manager:
		game_manager.handle_king_hit()

func reset():
	# Reset the king to upright position
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
