#lectureNotes 

hardness of a problem
if problem A can be solved with B, then B is at least as hard as A
L = {(M,x) | M accepts x} is undecidable by paradox

Talking about NP hardness
if A can be mapped into B, then B is at least as hard as A

\all x \in L, \exists c

Definition: of an NP machine
Set of all L (0,1)^* such that \exist polynomial P, deterministic 
V such that \all x \in L, \exists C \in {0,1}^(P(n)) |x| = n
	V(x,C) = 1
\all x \notin L \all C \in {0,1}^(P(n))
	V(x,C) = 0

NPHard:
Any B is NPHard
\all A \in NP, A reduces in poly time to B