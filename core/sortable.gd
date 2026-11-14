## Object to be sorted and compared in games with others of its kind.
class_name Sortable
extends RefCounted

var name: String
var rating: Rating


func _init(
	input_name: String = "Unknown",
	input_score: float = 0.0,
	input_doubt: float = Rating.MAX_DOUBT,
	input_volatility: float = Rating.DEFAULT_VOLATILITY,
	input_last_updated: String = "",
) -> void:
	name = input_name
	rating = Rating.new(input_score, input_doubt, input_volatility, input_last_updated)
