class_name Sortable
extends RefCounted

const MAX_DOUBT := 400.0

var name: String
var score: float
var doubt: float

func _init(
	input_name: String = "Unknown",
	input_score: float = 0.0,
	input_doubt: float = MAX_DOUBT,
) -> void:
	name = input_name
	score = input_score
	doubt = input_doubt
