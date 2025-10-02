#lectureNotes 
moving onto space complexity
disregard input, but count everything else
$$S: \mathbf{N} \rightarrow \mathbf{N} $$
$$ L \in DSPACE(S(n)) $$
$$PSPACE = \bigcup_{c>0} DSPACE(n^c)$$
$$ L = DSPACE(log(n))$$
Polytime contains LogSpace
PSpace contains NP and P
EXP contains PSpace

$$ \text{A is PSPACE hard if }\forall L \in PSPACE; L \leq_\text{Polytime} A $$
$$ \exists V \forall D^1 \forall D^2 ((D^1 = V_\text{start} \land D^2 = V) \lor (D^1 = V \land D^2 = V_\text{acc})) \rightarrow \psi_{i-1}(D^1,D^2) $$
