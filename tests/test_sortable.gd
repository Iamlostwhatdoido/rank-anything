extends GutTest


func test_new_sortable_has_default_values() -> void:
	# Arrange / Act :
	var test_sortable := Sortable.new()
	
	# Assert :
	assert_eq(test_sortable.name, "Unknown", "Nom par défaut")
	assert_eq(test_sortable.rating.score, 0.0, "Score par défaut")
	assert_eq(test_sortable.rating.doubt, 400.0, "Doubt par défaut")
	assert_eq(test_sortable.rating.volatility, 0.06, "Volatility par défaut")
	assert_eq(test_sortable.rating.date, "", "Date par défaut")


func test_new_sortable_keeps_given_values() -> void:
	# Arrange / Act :
	var test_sortable := Sortable.new("Michel", -35.5, 10.5, 0.1, "2020-10-27")
	
	# Assert :
	assert_eq(test_sortable.name, "Michel", "Nom défini")
	assert_eq(test_sortable.rating.score, -35.5, "Score défini")
	assert_eq(test_sortable.rating.doubt, 10.5, "Doubt défini")
	assert_eq(test_sortable.rating.volatility, 0.1, "Volatility définie")
	assert_eq(test_sortable.rating.date, "2020-10-27", "Date définie")
