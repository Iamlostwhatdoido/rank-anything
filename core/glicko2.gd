## Glicko2 rating engine
class_name Glicko2
extends RefCounted

## Differs from glicko so that a difference of STANDARD_GAP score gives a 90% expected victory.
const EXPECTANCY_BASE := 9.0
const STANDARD_GAP := 400.0
const SCALE: float = STANDARD_GAP / log(EXPECTANCY_BASE)

## Step 5 of Glickman's paper: ε.
const VOLATILITY_CONVERGENCE_TOLERANCE := 0.000001
## Step 5 of Glickman's paper: while loops safety caps.
const MAX_ITERATIONS := 100


# --- CONVERSION ---

static func to_internal(input: float) -> float:
	return input / SCALE


static func to_external(input: float) -> float:
	return input * SCALE


# --- PER-DUEL TERMS ---

## To estimate the variance, all duels' information is summed for each sortable.
static func compute_duel_information(
	mu: float,
	mu_opponent: float,
	phi_opponent: float,
) -> float:
	var expected_result := compute_expectancy(mu, mu_opponent, phi_opponent)
	return (compute_relevancy(phi_opponent) ** 2) * expected_result * (1 - expected_result)


## To estimate the improvement, all duels' deviations are summed for each sortable.
static func compute_duel_deviation(
	mu: float,
	mu_opponent: float,
	phi_opponent: float,
	s_result: float,
) -> float:
	var expected_result := compute_expectancy(mu, mu_opponent, phi_opponent)
	return compute_relevancy(phi_opponent) * (s_result - expected_result)


## Relevancy of a fighter, using its doubt (φ).[br]
## Step 3 of Glickman's paper: g(φ).
static func compute_relevancy(phi: float) -> float:
	return 1 / sqrt(1 + 3 * (phi / PI) ** 2)


## Expectancy of a duel, using opponent's ratings.[br]
## Step 3 of Glickman's paper: E(µ,µj,φj).
static func compute_expectancy(mu: float, mu_opponent: float, phi_opponent: float) -> float:
	return 1 / (1 + exp(-compute_relevancy(phi_opponent) * (mu - mu_opponent)))


# --- PERIOD ESTIMATIONS ---

## Estimated variance of the rating, based on game outcomes.[br]
## Step 3 of Glickman's paper: v(µ,µj,φj).[br]
static func estimate_variance(information_sum: float) -> float:
	assert(information_sum > 0.0, "The partial sum must be strictly positive.")
	return 1 / information_sum


## Step 4 of Glickman's paper: ∆.[br]
static func estimate_improvement(
	variance: float,
	deviation_sum: float,
) -> float:
	return variance * deviation_sum


# --- NEW RATING VALUES ---

## Step 5 of Glickman's paper: σ'.
static func compute_new_volatility(
	volatility: float,
	phi: float,
	variance: float,
	improvement: float,
	tau: float,
) -> float:
	# Step 5.1: Definitions
	var a := log(volatility ** 2)
	var known_uncertainty := phi ** 2 + variance
	var surprise := improvement ** 2 - known_uncertainty
	
	var volatility_equation := func (x: float) -> float:
		var exp_x := exp(x)
		var numerator := exp_x * (surprise - exp_x)
		var denominator := 2 * (known_uncertainty + exp_x) ** 2
		return numerator / denominator - (x - a) / tau ** 2
	
	# Step 5.2 & 3: Setting the bounds and their images.
	var bound_a := a
	var f_a: float = volatility_equation.call(bound_a)
	var bound_b := _find_bound_b(a, tau, volatility_equation, surprise)
	if is_nan(bound_b):
		return volatility
	var f_b: float = volatility_equation.call(bound_b)
	
	# Step 5.4 & 5: Illinois convergence loop, and return.
	var iter := 0
	while absf(bound_b - bound_a) > VOLATILITY_CONVERGENCE_TOLERANCE and iter < MAX_ITERATIONS:
		iter += 1
		var bound_c := bound_a + ((bound_a - bound_b) * f_a) / (f_b - f_a)
		var f_c: float = volatility_equation.call(bound_c)
		if f_c * f_b <= 0:
			bound_a = bound_b
			f_a = f_b
		else:
			f_a /= 2.0
		bound_b = bound_c
		f_b = f_c
	
	if absf(bound_b - bound_a) > VOLATILITY_CONVERGENCE_TOLERANCE:
		push_warning("Volatility: Illinois did not converge after %d iterations" % MAX_ITERATIONS)
		return volatility
	return exp(bound_a / 2.0)


## Helper: Iterative loop used in Glickman's paper step 5.2. [br]
## Finds bound B such that the equation changes sign between A and B.
static func _find_bound_b(
	a: float,
	tau: float,
	volatility_equation: Callable,
	surprise: float,
) -> float:
	if surprise > 0:
		return log(surprise)
	
	var k := 1
	while volatility_equation.call(a - k * tau) < 0 and k < MAX_ITERATIONS:
		k += 1
	
	if volatility_equation.call(a - k * tau) < 0:
		push_warning("Volatility: Bound B search did not converge after %d iterations" % MAX_ITERATIONS)
		return NAN
	return a - k * tau


## Step 6 of Glickman's paper: φ*.
static func compute_prerating_period_phi(phi: float, new_volatility: float) -> float:
	return sqrt(phi ** 2 + new_volatility ** 2)


## Step 7 of Glickman's paper: φ'.
static func compute_new_phi(prerating_phi: float, variance: float) -> float:
	return 1 / sqrt(1 / prerating_phi ** 2 + 1 / variance)


## Step 7 of Glickman's paper: μ'. [br]
static func compute_new_mu(mu: float, new_phi: float, deviation_sum: float) -> float:
	return mu + new_phi ** 2 * deviation_sum
