extends GutTest

var win1: Sortable
var win2: Sortable
var win3: Sortable
var los1: Sortable
var los2: Sortable

var winners: Array[Sortable]
var losers: Array[Sortable]


func before_each() -> void:
	win1 = Sortable.new("Winner 1")
	win2 = Sortable.new("Winner 2")
	win3 = Sortable.new("Winner 3")
	los1 = Sortable.new("Loser 1")
	los2 = Sortable.new("Loser 2")
	
	winners = [win1, win2, win3]
	losers = [los1, los2]


func test_new_from_match() -> void:
	# Arrange / Act :
	var test_game := Game.new_from_match(winners, losers)
	
	# Assert :
	assert_eq(test_game.rankings.size(), 5, "The game contains 5 participants")
	assert_eq(test_game.rankings[win1], 1, "Winner 1 is rank 1")
	assert_eq(test_game.rankings[win2], 1, "Winner 2 is rank 1")
	assert_eq(test_game.rankings[win3], 1, "Winner 3 is rank 1")
	assert_eq(test_game.rankings[los1], 2, "Loser 1 is rank 2")
	assert_eq(test_game.rankings[los2], 2, "Loser 2 is rank 2")


func test_add_ranking() -> void:
	# Arrange :
	var participant := Sortable.new("Michel")
	var test_game := Game.new()
	
	# Act :
	test_game.add_ranking(participant, 3)
	
	# Assert :
	assert_eq(test_game.rankings[participant], 3, "Michel is rank 3")


func test_group_by_rank() -> void:
	# Arrange :
	var test_game := Game.new_from_match(winners, losers)
	
	# Act :
	var grouped_rankings := test_game.group_by_rank()
	
	# Assert :
	assert_eq(grouped_rankings.size(), 2, "There are 2 ranks")
	assert_eq(grouped_rankings[1].size(), 3, "There are 3 winners")
	assert_eq(grouped_rankings[2].size(), 2, "There are 2 losers")
	assert_has(grouped_rankings[1], win1, "Winner 1 is in rank 1")
	assert_has(grouped_rankings[1], win2, "Winner 2 is in rank 1")
	assert_has(grouped_rankings[1], win3, "Winner 3 is in rank 1")
	assert_has(grouped_rankings[2], los1, "Loser 1 is in rank 2")
	assert_has(grouped_rankings[2], los2, "Loser 2 is in rank 2")


func test_no_losers() -> void:
	# Arrange :
	losers = []
	
	# Act :
	var test_game := Game.new_from_match(winners, losers)
	var grouped_rankings := test_game.group_by_rank()
	
	# Assert :
	assert_eq(test_game.rankings.size(), 3, "The game contains 3 participants")
	assert_has(grouped_rankings.keys(), 1, "There are winners")
	assert_does_not_have(grouped_rankings.keys(), 2, "There are no losers")
	assert_eq(grouped_rankings.size(), 1, "Only one rank")


## Score of the duel between x and y, seen from x, whichever side x is on in the Duel.
## Fails the test (fail_test) and returns -1.0 if there is no duel between x and y.
func _score_between(duels: Array[Duel], x: Sortable, y: Sortable) -> float:
	var candidate_duels: Array[Duel] = []
	for duel in duels:
		if duel.has(x) and duel.has(y):
			candidate_duels.append(duel)
	
	if candidate_duels.is_empty():
		fail_test("No duel found between %s and %s" % [x.name, y.name])
		return -1.0
	elif candidate_duels.size() > 1:
		fail_test("Multiple duels found between %s and %s" % [x.name, y.name])
		return -1.0
	else:
		return candidate_duels[0].get_result_of(x)


func test_get_duels_single_participant() -> void:
	# Arrange :
	var test_game := Game.new()
	test_game.add_ranking(win1, 1)

	# Act / Assert :
	assert_eq(test_game.get_duels().size(), 0, "A lone participant has no duel")


func test_get_duels_empty_game() -> void:
	# Arrange / Act / Assert :
	assert_eq(Game.new().get_duels().size(), 0, "An empty game has no duel")


func test_get_duels_scores() -> void:
	# Arrange :
	var test_game := Game.new_from_match(winners, losers)

	# Act :
	var duels := test_game.get_duels()

	# Assert :
	assert_eq(_score_between(duels, win1, los1), 1.0, "Winner 1 beats Loser 1")
	assert_eq(_score_between(duels, los2, win3), 0.0, "Loser 2 loses to Winner 3")
	assert_eq(_score_between(duels, win1, win2), 0.5, "Two winners draw")
	assert_eq(_score_between(duels, los1, los2), 0.5, "Two losers draw")


func test_get_duels_every_pair_once() -> void:
	# Arrange :
	var test_game := Game.new_from_match(winners, losers)
	var participants: Array[Sortable] = [win1, win2, win3, los1, los2]

	# Act :
	var duels := test_game.get_duels()

	# Assert : with exactly 10 duels, finding all 10 pairs proves none is missing or doubled.
	assert_eq(duels.size(), 10, "10 duels")
	for i in participants.size():
		for j in range(i + 1, participants.size()):
			assert_ne(_score_between(duels, participants[i], participants[j]), -1.0,
				"%s and %s have a duel" % [participants[i].name, participants[j].name])
