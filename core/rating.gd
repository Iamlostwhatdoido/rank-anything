## Dated Glicko-2 estimate of a Sortable’s strength.
class_name Rating
extends RefCounted

const MIN_DOUBT := 30.0
## Also assigned for unknown sortables.
const MAX_DOUBT := 400.0
const DEFAULT_VOLATILITY := 0.06

## Centered around 0, not 1500.
var score: float
## Named 'RD' in Glicko-2.
var doubt: float
var volatility: float
## Convention: YYYY-MM-DD. For 'never updated', use "" value.
var date: String


func _init(
	input_score: float = 0.0,
	input_doubt: float = MAX_DOUBT,
	input_volatility: float = DEFAULT_VOLATILITY,
	input_date: String = "",
) -> void:
	score = input_score
	doubt = input_doubt
	volatility = input_volatility
	date = input_date
