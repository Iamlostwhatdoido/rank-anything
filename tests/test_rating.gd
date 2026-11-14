# ai_generated: unreviewed
extends GutTest


func test_new_rating_has_default_values() -> void:
	# Arrange / Act :
	var rating := Rating.new()

	# Assert :
	assert_eq(rating.score, 0.0, "Default score is the middle of the ranking")
	assert_eq(rating.doubt, Rating.MAX_DOUBT, "Default doubt is the maximum")
	assert_eq(rating.volatility, Rating.DEFAULT_VOLATILITY, "Default volatility")
	assert_eq(rating.date, "", "Never updated")


func test_new_rating_keeps_given_values() -> void:
	# Arrange / Act :
	var rating := Rating.new(-35.5, 151.5, 0.05, "2026-11-14")

	# Assert :
	assert_eq(rating.score, -35.5, "Score kept")
	assert_eq(rating.doubt, 151.5, "Doubt kept")
	assert_eq(rating.volatility, 0.05, "Volatility kept")
	assert_eq(rating.date, "2026-11-14", "Date kept")


func test_doubt_bounds_are_ordered() -> void:
	# Assert :
	assert_lt(Rating.MIN_DOUBT, Rating.MAX_DOUBT, "The doubt floor is below the ceiling")


func test_sortables_do_not_share_a_rating() -> void:
	# Arrange / Act :
	var first := Sortable.new("First")
	var second := Sortable.new("Second")

	# Assert :
	assert_ne(first.rating, second.rating, "Each Sortable owns its own Rating")
