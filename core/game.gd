## Stores results of a game, tiering Sortables by ranks.
class_name Game
extends RefCounted

## Convention: lower ranks are better.
var rankings: Dictionary[Sortable, int]


## Winners are ranked 1. Losers are ranked 2.
static func new_from_match(winners: Array[Sortable], losers: Array[Sortable]) -> Game:
	var new_game := Game.new()
	
	for winner in winners:
		new_game.add_ranking(winner, 1)
	for loser in losers:
		new_game.add_ranking(loser, 2)
	
	return new_game


func add_ranking(new_participant: Sortable, rank: int) -> void:
	assert(not new_participant in rankings, "The sortable is already in the current Game")
	rankings[new_participant] = rank


## Keys follow insertion order, output is unsorted.
func group_by_rank() -> Dictionary[int, Array]:
	var grouped_by_rank: Dictionary[int, Array]

	for participant in rankings:
		var rank := rankings[participant]
		var rank_population: Array = grouped_by_rank.get_or_add(rank, [])
		rank_population.append(participant)

	return grouped_by_rank


func get_duels() -> Array[Duel]:
	var duel_list: Array[Duel] = []
	
	var fighter_list = rankings.keys()
	
	for a_id in range(fighter_list.size()):
		var fighter_a: Sortable = fighter_list[a_id]
		
		for b_id in range(a_id+1, fighter_list.size()):
			var fighter_b: Sortable = fighter_list[b_id]
			
			var new_duel := Duel.new_from_rank(fighter_a, rankings[fighter_a], fighter_b, rankings[fighter_b])
			duel_list.append(new_duel)
	
	return duel_list
