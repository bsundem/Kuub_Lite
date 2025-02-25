extends Node

# Game state constants
enum GameState {
	SETUP,
	PLAYER_TURN,
	AI_TURN,
	GAME_OVER
}

# Team constants
enum Team {
	TEAM_A,
	TEAM_B
}

# Game configuration
const FIELD_LENGTH = 8.0  # meters
const FIELD_WIDTH = 5.0   # meters
const KUBBS_PER_TEAM = 5

# Current game state
var current_state: int = GameState.SETUP
var current_team: int = Team.TEAM_A
var winner: int = -1

# Game pieces tracking
var team_a_kubbs = []
var team_b_kubbs = []
var field_kubbs = []  # Kubbs that have been knocked over and thrown to opposing side
var king = null
var batons = []

# Score tracking
var team_a_score = 0
var team_b_score = 0

func _ready():
	initialize_game()

func initialize_game():
	# Reset game state
	current_state = GameState.SETUP
	current_team = Team.TEAM_A
	winner = -1
	
	# Clear any existing piece references
	team_a_kubbs.clear()
	team_b_kubbs.clear()
	field_kubbs.clear()
	batons.clear()
	
	# Setup will be handled by the main scene
	# This function will be called when all pieces are in place
	print("Game initialized, setting up the field...")

func start_game():
	current_state = GameState.PLAYER_TURN
	print("Game started! Team A goes first.")

func switch_turns():
	if current_team == Team.TEAM_A:
		current_team = Team.TEAM_B
	else:
		current_team = Team.TEAM_A
	
	print("Now it's Team ", "A" if current_team == Team.TEAM_A else "B", "'s turn")

func check_for_win():
	# Win condition: All opponent's kubbs and the king are knocked down
	var team_a_wins = team_b_kubbs.size() == 0 and king.is_knocked_over()
	var team_b_wins = team_a_kubbs.size() == 0 and king.is_knocked_over()
	
	if team_a_wins:
		winner = Team.TEAM_A
		current_state = GameState.GAME_OVER
		print("Team A wins!")
		return true
	elif team_b_wins:
		winner = Team.TEAM_B
		current_state = GameState.GAME_OVER
		print("Team B wins!")
		return true
	
	return false

func throw_baton(baton, direction, force):
	# Apply physics force to the baton
	if current_state != GameState.PLAYER_TURN and current_state != GameState.AI_TURN:
		return
	
	print("Throwing baton with force: ", force)
	# The actual physics will be handled by the baton script
	# This is just the logic to track the throw

func handle_kubb_hit(kubb):
	# When a kubb is hit, update game state
	print("Kubb hit: ", kubb.name)
	# Logic for handling hit kubbs will go here

func handle_king_hit():
	# Special handling for when the king is hit
	print("King hit!")
	# Logic for handling the king being hit

# Called to process a completed turn
func end_turn():
	if check_for_win():
		return
	
	switch_turns()
