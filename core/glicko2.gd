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


static func to_internal(input: float) -> float:
	return input / SCALE


static func to_external(input: float) -> float:
	return input * SCALE


## Relevancy of a fighter, using its doubt (φ).[br]
## Step 3 of Glickman's paper: g(φ).
static func relevancy(phi: float) -> float:
	return 1 / sqrt(1 + 3 * (phi / PI) ** 2)


## Expectancy of a duel, using opponent's ratings.[br]
## Step 3 of Glickman's paper: E(µ,µj,φj).
static func expectancy(mu: float, mu_opponent: float, phi_opponent: float) -> float:
	return 1 / (1 + exp(-relevancy(phi_opponent) * (mu - mu_opponent)))


## Estimated variance of the rating, based on game outcomes.[br]
## Step 3 of Glickman's paper: v(µ,µj,φj).[br]
## Takes the sum of every duel_variance_impact of a session.
static func variance(accumulated_variance_impact: float) -> float:
	assert(accumulated_variance_impact > 0.0, "The impact must be strictly positive.")
	return 1 / accumulated_variance_impact


## During session computation, duel_variance_impacts will be accumulated for each sortables.
static func duel_variance_impact(
	mu: float,
	mu_opponent: float,
	phi_opponent: float,
) -> float:
	var expected_result := expectancy(mu, mu_opponent, phi_opponent)
	return (relevancy(phi_opponent) ** 2) * expected_result * (1 - expected_result)


## Change to apply to the score, based on game outcomes.[br]
## Step 4 of Glickman's paper: ∆.[br]
## Takes the sum of every duel_improvement_impact of a session.
static func improvement(
	computed_variance: float,
	accumulated_improvement_impact: float,
) -> float:
	return computed_variance * accumulated_improvement_impact


## During session computation, duel_improvement_impacts will be accumulated for each sortables.
static func duel_improvement_impact(
	mu: float,
	mu_opponent: float,
	phi_opponent: float,
	s_result: float,
) -> float:
	return relevancy(phi_opponent) * (s_result - expectancy(mu, mu_opponent, phi_opponent))


## Step 5 of Glickman's paper: σ'.
static func volatility(
	previous_volatility: float,
	phi: float,
	computed_variance: float,
	computed_improvement: float,
	tau: float,
) -> float:
	# Step 5.1: Definitions
	var a := log(previous_volatility ** 2)
	var known_uncertainty := phi ** 2 + computed_variance
	var surprise := computed_improvement ** 2 - known_uncertainty
	
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
		return previous_volatility
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
		return previous_volatility
	return exp(bound_a / 2.0)


## Iterative loop used in Glickman's paper step 5.2. [br]
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
