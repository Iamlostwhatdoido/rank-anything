extends GutTest

# --- GLICKMAN'S EXAMPLE ---
# Raw inputs: the paper's own numbers, converted with the paper's own scale.
const OFFICIAL_STD_GAP := 400.0
const OFFICIAL_BASE := 10.0
const OFFICIAL_SCALE := OFFICIAL_STD_GAP / log(OFFICIAL_BASE)
const OFFICIAL_TAU := 0.5

# Paper's intermediary calculations.
# Glickman rounded, and then used those values for the next step.
# Expect deviations from true values.
const PAPER_PHI := 1.1513
const PAPER_VARIANCE := 1.7785
const PAPER_IMPROVEMENT := -0.4834
const PAPER_NEW_VOLATILITY := 0.05999
const PAPER_PRERATING_PHI := 1.152862
const PAPER_NEW_PHI := 0.8722
const PAPER_NEW_MU := -0.2069

var main_fighter: Dictionary[String, float]
var opponents: Array[Dictionary]


func before_each() -> void:
	main_fighter = {
		"mu": (1500 - 1500) / OFFICIAL_SCALE,
		"phi": 200 / OFFICIAL_SCALE,
		"volatility": 0.06,
	}
	
	opponents = [
		{"mu": (1400 - 1500) / OFFICIAL_SCALE, "phi": 30  / OFFICIAL_SCALE, "result": 1.0},
		{"mu": (1550 - 1500) / OFFICIAL_SCALE, "phi": 100 / OFFICIAL_SCALE, "result": 0.0},
		{"mu": (1700 - 1500) / OFFICIAL_SCALE, "phi": 300 / OFFICIAL_SCALE, "result": 0.0},
	]


# --- HELPERS ---

func _sum_variance_impacts() -> float:
	var total := 0.0
	
	for opponent in opponents:
		total += Glicko2.duel_variance_impact(
				main_fighter.mu, opponent.mu, opponent.phi)
	
	return total


func _sum_improvement_impacts() -> float:
	var total := 0.0
	
	for opponent in opponents:
		total += Glicko2.duel_improvement_impact(
				main_fighter.mu, opponent.mu, opponent.phi, opponent.result)
	
	return total


# --- UNIT TESTS ---

func test_relevancy() -> void:
	# The paper_relevancies are hardcoded here, because not needed globally.
	var paper_relevancies := [0.9955, 0.9531, 0.7242]
	for i in opponents.size():
		var relevancy := Glicko2.relevancy(opponents[i].phi)
		assert_almost_eq(relevancy, paper_relevancies[i], 0.0001, "of opponent %d" % (i + 1))


func test_expectancy() -> void:
	# The paper_expectancies are hardcoded here, because not needed globally.
	var paper_expectancies := [0.639, 0.432, 0.303]
	for i in opponents.size():
		var expectancy := Glicko2.expectancy(main_fighter.mu, opponents[i].mu, opponents[i].phi)
		assert_almost_eq(expectancy, paper_expectancies[i], 0.001, "against opponent %d" % (i + 1))


func test_variance() -> void:
	# The paper computes v from E rounded to 3 decimals. Full precision gives 1.77898
	var variance := Glicko2.variance(_sum_variance_impacts())
	assert_almost_eq(variance, PAPER_VARIANCE, 0.001)


func test_improvement() -> void:
	# The paper computes v from E rounded to 3 decimals. Full precision gives -0.48393
	var improvement := Glicko2.improvement(PAPER_VARIANCE, _sum_improvement_impacts())
	assert_almost_eq(improvement, PAPER_IMPROVEMENT, 0.001)


func test_volatility() -> void:
	var new_volatility := Glicko2.volatility(
			main_fighter.volatility, PAPER_PHI, PAPER_VARIANCE, PAPER_IMPROVEMENT, OFFICIAL_TAU)
	assert_almost_eq(new_volatility, PAPER_NEW_VOLATILITY, 0.00001)


func test_prerating_period_phi() -> void:
	var prerating_phi := Glicko2.prerating_period_phi(PAPER_PHI, PAPER_NEW_VOLATILITY)
	assert_almost_eq(prerating_phi, PAPER_PRERATING_PHI, 0.000001)


func test_new_phi() -> void:
	var new_phi := Glicko2.new_phi(PAPER_PRERATING_PHI, PAPER_VARIANCE)
	assert_almost_eq(new_phi, PAPER_NEW_PHI, 0.0001)


func test_new_mu() -> void:
	# The paper does not publish the raw sum: found through improvement / variance.
	var paper_sum_improvement_impacts := PAPER_IMPROVEMENT / PAPER_VARIANCE
	var new_mu := Glicko2.new_mu(main_fighter.mu, PAPER_NEW_PHI, paper_sum_improvement_impacts)
	assert_almost_eq(new_mu, PAPER_NEW_MU, 0.001)


# --- END-TO-END CHAIN ---

func test_full_chain() -> void:
	var variance := Glicko2.variance(_sum_variance_impacts())
	var sum_improvement_impacts := _sum_improvement_impacts()
	var improvement := Glicko2.improvement(variance, sum_improvement_impacts)
	
	var new_volatility := Glicko2.volatility(
			main_fighter.volatility, main_fighter.phi, variance, improvement, OFFICIAL_TAU)
	var prerating_phi := Glicko2.prerating_period_phi(main_fighter.phi, new_volatility)
	var new_phi := Glicko2.new_phi(prerating_phi, variance)
	var new_mu := Glicko2.new_mu(main_fighter.mu, new_phi, sum_improvement_impacts)
	
	# Assert : full precision drifts from the paper's rounded chain, hence 0.001.
	assert_almost_eq(new_volatility, PAPER_NEW_VOLATILITY, 0.00001, "sigma'")
	assert_almost_eq(new_phi, PAPER_NEW_PHI, 0.001, "phi'")
	assert_almost_eq(new_mu, PAPER_NEW_MU, 0.001, "mu'")


# --- CONVERSION TESTS ---

## The change of base to 9 was done by design so a standard gap of 400 yields 10-90% of expectancy.
func test_standard_gap_gives_10_90_percent() -> void:
	var mu1 := Glicko2.to_internal(0.0)
	var mu2 := Glicko2.to_internal(400.0)
	var phi_both := Glicko2.to_internal(0.0)

	var expected_result1 := Glicko2.expectancy(mu1, mu2, phi_both)
	var expected_result2 := Glicko2.expectancy(mu2, mu1, phi_both)
	
	assert_almost_eq(expected_result1, 0.1, 0.0001)
	assert_almost_eq(expected_result2, 0.9, 0.0001)


func test_conversion_round_trip() -> void:
	for value in [-1382.0, -35.5, 0.0, 30.0, 400.0, 1409.0]:
		var in_and_out := Glicko2.to_external(Glicko2.to_internal(value))
		assert_almost_eq(in_and_out, value, 0.0001, "round trip of %s" % value)


# --- OUT-OF-PAPER TESTS ---

## Property test: a big upset must raise the volatility (branch surprise > 0 of volatility).
func test_volatility_rises_after_upset() -> void:
	# Arrange : a well-known player (small phi) beats much stronger, well-known opponents.
	var underdog_mu := (1200 - 1500) / OFFICIAL_SCALE
	var underdog_volatility := 0.06
	var champion_mus: Array[float] = [
		(1400 - 1500) / OFFICIAL_SCALE,
		(1800 - 1500) / OFFICIAL_SCALE,
		(2000 - 1500) / OFFICIAL_SCALE,
	]
	var phi_all := 30.0 / OFFICIAL_SCALE
	
	var sum_variance := 0.0
	var sum_improvement := 0.0
	
	for champion_mu in champion_mus:
		sum_variance += Glicko2.duel_variance_impact(underdog_mu, champion_mu, phi_all)
		sum_improvement += Glicko2.duel_improvement_impact(underdog_mu, champion_mu, phi_all, 1.0)
	
	var upset_variance := Glicko2.variance(sum_variance)
	var upset_improvement := Glicko2.improvement(upset_variance, sum_improvement)
	
	# Guard : make sure the case really goes through the surprise > 0 branch.
	var surprise := upset_improvement ** 2 - phi_all ** 2 - upset_variance
	assert_gt(surprise, 0.0, "The surprise is indeed positive")
	
	var new_volatility := Glicko2.volatility(
			underdog_volatility, phi_all, upset_variance, upset_improvement, OFFICIAL_TAU)
	assert_gt(new_volatility, underdog_volatility, "A big upset raises the volatility")
