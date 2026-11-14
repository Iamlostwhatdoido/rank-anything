## Glicko2 rating engine
class_name Glicko2
extends RefCounted

## Differs from glicko so that a difference of STANDARD_GAP score gives a 90% expected victory.
const EXPECTANCY_BASE := 9.0
const STANDARD_GAP := 400.0

const SCALE: float = STANDARD_GAP / log(EXPECTANCY_BASE)


static func to_internal(input: float) -> float:
	return input/SCALE


static func to_external(input: float) -> float:
	return input*SCALE


## Relevancy of a fighter, using its doubt (φ).[br]
## Step 3 of Glickman's paper: g(φ).
static func relevancy(phi: float) -> float:
	return 1 / sqrt(1 + 3*(phi/PI)**2)


## Expectancy of a duel, using opponent's ratings.[br]
## Step 3 of Glickman's paper: E(µ,µj,φj).
static func expectancy(mu:float, mu_opponent: float, phi_opponent: float) -> float:
	return 1 / (1 + exp(-relevancy(phi_opponent) * (mu - mu_opponent)))


## Estimated variance of the rating, based only on game outcomes.[br]
## Step 3 of Glickman's paper: v(µ,µj,φj).[br]
## Takes the sum of every duel_variance_impact of a session.
static func variance(accumulated_variance_impact: float) -> float:
	return 1 / (accumulated_variance_impact)


## During session computation, duel_variance_impacts will be accumulated for each sortables.
static func duel_variance_impact(
	mu:float,
	mu_opponent: float,
	phi_opponent: float,
) -> float:
	var expected_result := expectancy(mu, mu_opponent, phi_opponent)
	return (relevancy(phi_opponent)**2)*expected_result*(1 - expected_result)


## Change to apply to the score, based on game outcomes.[br]
## Step 4 of Glickman's paper: ∆.[br]
## Takes the sum of every duel_improvement_impact of a session.
static func improvement(
	accumulated_variance_impact: float,
	accumulated_improvement_impact: float,
) -> float:
	return variance(accumulated_variance_impact)*accumulated_improvement_impact


## During session computation, duel_improvement_impacts will be accumulated for each sortables.
static func duel_improvement_impact(
	mu:float,
	s_result: float,
	mu_opponent: float,
	phi_opponent: float,
) -> float:
	return relevancy(phi_opponent)*(s_result-expectancy(mu, mu_opponent, phi_opponent))
