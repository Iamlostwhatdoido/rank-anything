## Manages a fight relationship between two Sortables.
class_name Duel
extends RefCounted


var fighter_a: Sortable
var fighter_b: Sortable
## Convention: From the POV of A. So 1.0 gives victory to A.
var duel_result: float


static func new_from_rank(
	input_fighter_a: Sortable,
	input_fighter_rank_a: int,
	input_fighter_b: Sortable,
	input_fighter_rank_b: int,
) -> Duel:
	var result: float
	
	if input_fighter_rank_a == input_fighter_rank_b:
		result = 0.5
	elif input_fighter_rank_a < input_fighter_rank_b:
		result = 1.0
	else:
		result = 0.0
	return Duel.new(input_fighter_a, input_fighter_b, result)

func _init(
	input_fighter_a: Sortable,
	input_fighter_b: Sortable,
	input_duel_result: float,
) -> void:
	assert(input_fighter_a != input_fighter_b, "The fighters must be different.")
	assert(input_duel_result >= 0.0 and input_duel_result <= 1.0, "The result must be within [0.0;1.0]")
	fighter_a = input_fighter_a
	fighter_b = input_fighter_b
	duel_result = input_duel_result


## Checks if the duel contains the fighter.
func has(fighter: Sortable) -> bool:
	return (fighter == fighter_a) or (fighter == fighter_b)


## Returns the duel result, from the pov of a given fighter.
func get_result_of(fighter: Sortable) -> float:
	assert(has(fighter), "The fighter must be in the duel")
	
	if fighter == fighter_a:
		return duel_result
	else:
		return 1.0 - duel_result
