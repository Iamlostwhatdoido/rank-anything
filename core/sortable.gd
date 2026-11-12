class_name Sortable
extends RefCounted

const MAX_DOUBT := 400.0
const DEFAULT_VOLATILITY := 0.06

var name: String
var score: float
var doubt: float
var volatility: float
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
