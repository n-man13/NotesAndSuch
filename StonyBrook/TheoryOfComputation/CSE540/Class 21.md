#lectureNotes

AM and MA

AM[2] has an input x and a random coin 
M sends proof to A
Arthur runs deterministic verifier(x, r, p) - yes or no

if $x \in L$ Pr[yes] \geq 2/3$
if $x \notin L; Pr[yes] \leq 1/3$

Parallel Repetition
M sends A a proof, and A tosses a coin. Majority of the time it is true if x is in L
For all possible 2^P(n) many a, at most 4^-P(n) many r that gives wrong answer
$$AMAM \subseteq AM$$
MIP = NEXP

PCP(logn, O(1)) = NP

Max-CSPSat

A gap problem has a PCP proof system iff it can be reduced to CSP
