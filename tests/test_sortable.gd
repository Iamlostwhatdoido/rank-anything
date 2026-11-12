extends GutTest


func test_new_sortable_has_default_values() -> void:
	# Arrange / Act : créer un Sortable sans aucun paramètre
	var test_sortable := Sortable.new()
	
	# Assert : vérifier son nom, son score et son doute par défaut
	assert_eq(test_sortable.name, "Unknown", "Nom par défaut")
	assert_eq(test_sortable.score, 0.0, "Score par défaut")
	assert_eq(test_sortable.doubt, 400.0, "Doubt par défaut")
	assert_eq(test_sortable.volatility, 0.06, "Volatility par défaut")


func test_new_sortable_keeps_given_values() -> void:
	# Arrange / Act : créer un Sortable avec un nom, un score et un doute choisis
	var test_sortable := Sortable.new("Michel", -35.5, 10.5, 0.1, "2020-10-27")
	
	# Assert : vérifier qu'il a gardé exactement ces trois valeurs
	assert_eq(test_sortable.name, "Michel", "Nom définit")
	assert_eq(test_sortable.score, -35.5, "Score définit")
	assert_eq(test_sortable.doubt, 10.5, "Doubt définit")
	assert_eq(test_sortable.last_updated, "2020-10-27", "Date définit")


func test_new_sortable_starts_with_max_doubt() -> void:
	# Arrange / Act : créer un Sortable avec seulement un nom
	var test_sortable := Sortable.new("Michel")
	
	# Assert : vérifier que son doute vaut la constante MAX_DOUBT (et non 400 écrit en dur)
	assert_eq(test_sortable.doubt, Sortable.MAX_DOUBT, "Doubt Maximum pour inconnu")
	assert_eq(test_sortable.volatility, Sortable.DEFAULT_VOLATILITY, "Default volatility pour inconnu")
	assert_eq(test_sortable.last_updated, Time.get_date_string_from_system(), "Default date pour inconnu")
