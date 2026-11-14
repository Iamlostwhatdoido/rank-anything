extends GutTest

var fighter_a: Sortable
var fighter_b: Sortable


func before_each() -> void:
	fighter_a = Sortable.new("Fighter A")
	fighter_b = Sortable.new("Fighter B")


func test_new() -> void:
	# Arrange / Act :
	var duel := Duel.new(fighter_a, fighter_b, 0.75)

	# Assert :
	assert_eq(duel.fighter_a, fighter_a, "Fighter A is kept as A")
	assert_eq(duel.fighter_b, fighter_b, "Fighter B is kept as B")
	assert_eq(duel.duel_result, 0.75, "The result is kept as given")


func test_new_from_rank_better_rank_wins() -> void:
	# Arrange / Act :
	var duel := Duel.new_from_rank(fighter_a, 1, fighter_b, 2)

	# Assert :
	assert_eq(duel.duel_result, 1.0, "Rank 1 beats rank 2: A wins")


func test_new_from_rank_worse_rank_loses() -> void:
	# Arrange / Act :
	var duel := Duel.new_from_rank(fighter_a, 3, fighter_b, 1)

	# Assert :
	assert_eq(duel.duel_result, 0.0, "Rank 3 loses to rank 1: A loses")


func test_new_from_rank_same_rank_draws() -> void:
	# Arrange / Act :
	var duel := Duel.new_from_rank(fighter_a, 2, fighter_b, 2)

	# Assert :
	assert_eq(duel.duel_result, 0.5, "Same rank: draw")


func test_new_from_rank_keeps_fighter_order() -> void:
	# Arrange / Act :
	var duel := Duel.new_from_rank(fighter_a, 2, fighter_b, 1)

	# Assert :
	assert_eq(duel.fighter_a, fighter_a, "The first fighter given stays A")
	assert_eq(duel.fighter_b, fighter_b, "The second fighter given stays B")


func test_has() -> void:
	# Arrange :
	var stranger := Sortable.new("Stranger")
	var duel := Duel.new(fighter_a, fighter_b, 1.0)

	# Act / Assert :
	assert_true(duel.has(fighter_a), "Fighter A is in the duel")
	assert_true(duel.has(fighter_b), "Fighter B is in the duel")
	assert_false(duel.has(stranger), "A stranger is not in the duel")


func test_get_result_of_win() -> void:
	# Arrange :
	var duel := Duel.new(fighter_a, fighter_b, 1.0)

	# Act / Assert :
	assert_eq(duel.get_result_of(fighter_a), 1.0, "A won")
	assert_eq(duel.get_result_of(fighter_b), 0.0, "B lost")


func test_get_result_of_loss() -> void:
	# Arrange :
	var duel := Duel.new(fighter_a, fighter_b, 0.0)

	# Act / Assert :
	assert_eq(duel.get_result_of(fighter_a), 0.0, "A lost")
	assert_eq(duel.get_result_of(fighter_b), 1.0, "B won")


func test_get_result_of_draw() -> void:
	# Arrange :
	var duel := Duel.new(fighter_a, fighter_b, 0.5)

	# Act / Assert :
	assert_eq(duel.get_result_of(fighter_a), 0.5, "Draw, seen from A")
	assert_eq(duel.get_result_of(fighter_b), 0.5, "Draw, seen from B")
