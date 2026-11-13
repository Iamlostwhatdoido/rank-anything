## Object to be sorted and compared in games with others of its kind.
class_name Sortable
extends RefCounted

## Also assigned at creation for new sortables.
const MAX_DOUBT := 400.0
const DEFAULT_VOLATILITY := 0.06

var name: String
## Centered around 0, not 1500.
var score: float
## Named 'RD' in Glicko-2.
var doubt: float
var volatility: float
## Convention: YYYY-MM-DD. For 'never updated', use "" value.
var last_updated: String


func _init(
	input_name: String = "Unknown",
	input_score: float = 0.0,
	input_doubt: float = MAX_DOUBT,
	input_volatility: float = DEFAULT_VOLATILITY,
	input_last_updated: String = "",
) -> void:
	name = input_name
	score = input_score
	doubt = input_doubt
	volatility = input_volatility
	last_updated = input_last_updated
