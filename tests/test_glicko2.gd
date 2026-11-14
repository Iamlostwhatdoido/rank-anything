extends GutTest

const OFFICIAL_STD_GAP := 400.0
const OFFICIAL_BASE := 10.0
const OFFICIAL_SCALE := OFFICIAL_STD_GAP/log(OFFICIAL_BASE)

var mu_main: float
var mu_opp1: float
var mu_opp2: float
var mu_opp3: float

var phi_main: float
var phi_opp1: float
var phi_opp2: float
var phi_opp3: float

var result_vs1: float
var result_vs2: float
var result_vs3: float

var volatility_main: float


func before_each():
	mu_main = (1500 - 1500)/OFFICIAL_SCALE
	mu_opp1 = (1400 - 1500)/OFFICIAL_SCALE
	mu_opp2 = (1550 - 1500)/OFFICIAL_SCALE
	mu_opp3 = (1700 - 1500)/OFFICIAL_SCALE

	phi_main = 200/OFFICIAL_SCALE
	phi_opp1 = 30/OFFICIAL_SCALE
	phi_opp2 = 100/OFFICIAL_SCALE
	phi_opp3 = 300/OFFICIAL_SCALE
	
	result_vs1 = 1.0
	result_vs2 = 0.0
	result_vs3 = 0.0
	
	volatility_main = 0.06


func test_standard_gap_gives_10_90_percent() -> void:
	# Arrange :
	var score1 := 0.0
	var score2 := 400.0
	var doubt_both := 0.0
	
	# Act :
	var mu1 := Glicko2.to_internal(score1)
	var mu2 := Glicko2.to_internal(score2)
	var phi_both := Glicko2.to_internal(doubt_both)
	var expected_result1 := Glicko2.expectancy(mu1, mu2, phi_both)
	var expected_result2 := Glicko2.expectancy(mu2, mu1, phi_both)
	
	# Assert :
	assert_almost_eq(expected_result1, 0.1, 0.0001, "Scale designed so a standard gap yields 10%-90% win-lose diff.")
	assert_almost_eq(expected_result2, 0.9, 0.0001, "Reciprocal.")


func test_conversion_round_trip() -> void:
	# Arrange / Act / Assert:
	for value in [-1382.0, -35.5, 0.0, 30.0, 400.0, 1409.0]:
		var in_and_out := Glicko2.to_external(Glicko2.to_internal(value))
		assert_almost_eq(in_and_out, value, 0.0001, "round trip of %s" % value)


func test_relevancy() -> void:
	# Arrange / Act :
	var g1 := Glicko2.relevancy(phi_opp1)
	var g2 := Glicko2.relevancy(phi_opp2)
	var g3 := Glicko2.relevancy(phi_opp3)
	
	# Assert :
	assert_almost_eq(g1, 0.9955, 0.0001, "relevancy(phi_opp1) computation")
	assert_almost_eq(g2, 0.9531, 0.0001, "relevancy(phi_opp2) computation")
	assert_almost_eq(g3, 0.7242, 0.0001, "relevancy(phi_opp3) computation")


func test_expectancy() -> void:
	# Arrange / Act :
	var E1 := Glicko2.expectancy(mu_main, mu_opp1, phi_opp1)
	var E2 := Glicko2.expectancy(mu_main, mu_opp2, phi_opp2)
	var E3 := Glicko2.expectancy(mu_main, mu_opp3, phi_opp3)
	
	# Assert :
	assert_almost_eq(E1, 0.639, 0.001, "expectancy(main vs opp1) computation")
	assert_almost_eq(E2, 0.432, 0.001, "expectancy(main vs opp2) computation")
	assert_almost_eq(E3, 0.303, 0.001, "expectancy(main vs opp3) computation")


func test_variance() -> void:
	# Arrange
	var accumulated_variance_impact := 0.0
	
	accumulated_variance_impact += Glicko2.duel_variance_impact(mu_main, mu_opp1, phi_opp1)
	accumulated_variance_impact += Glicko2.duel_variance_impact(mu_main, mu_opp2, phi_opp2)
	accumulated_variance_impact += Glicko2.duel_variance_impact(mu_main, mu_opp3, phi_opp3)
	
	# Act :
	var variance := Glicko2.variance(accumulated_variance_impact)
	
	# Assert : The paper computes v from E rounded to 3 decimals: full precision gives 1.77898
	assert_almost_eq(variance, 1.7785, 0.001, "variance(main vs all) computation")


func test_improvement() -> void:
	# Arrange :
	var accumulated_variance_impact := 0.0
	var accumulated_improvement_impact := 0.0
	
	accumulated_variance_impact += Glicko2.duel_variance_impact(mu_main, mu_opp1, phi_opp1)
	accumulated_variance_impact += Glicko2.duel_variance_impact(mu_main, mu_opp2, phi_opp2)
	accumulated_variance_impact += Glicko2.duel_variance_impact(mu_main, mu_opp3, phi_opp3)
	accumulated_improvement_impact += Glicko2.duel_improvement_impact(mu_main, result_vs1, mu_opp1, phi_opp1)
	accumulated_improvement_impact += Glicko2.duel_improvement_impact(mu_main, result_vs2, mu_opp2, phi_opp2)
	accumulated_improvement_impact += Glicko2.duel_improvement_impact(mu_main, result_vs3, mu_opp3, phi_opp3)
	
	# Act :
	var improvement := Glicko2.improvement(accumulated_variance_impact, accumulated_improvement_impact)
	
	# Assert : The paper computes v from E rounded to 3 decimals: full precision gives -0.48393
	assert_almost_eq(improvement, -0.4834, 0.001, "improvement(main vs all) computation")
