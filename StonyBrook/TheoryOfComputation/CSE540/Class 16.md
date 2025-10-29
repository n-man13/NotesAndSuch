#lectureNotes 
Theorem:
$BPP \subseteq P/poly$
Proof:
	Claim 1: A language L \in BPP iff there exists a deterministic 2 input TM M running in poly time and a poly P(n) such that $x \in L \leftrightarrow Pr_{r = \{0,1\}}[M(x,r)=L(x)]=2/3$
	1. Error Reduction (Generally first step in any bpp proof)
		There exists a polytime TM M' such that $$x \in L \leftrightarrow Pr_r[M'(x,r)=L(x)]=2^{-2n}$$
	2. Use P $\subseteq$ P/poly
		Then $$x \in L \leftrightarrow  Pr_{{r = \{0,1\}}^{poly(n)}}[C(x,r) \neq L(x)] leq 2^{-2n} where |C| = poly(n)$$
	Claim: For every n, $\exists r* \in \{0,1\}^{poly(n)} such that C(x,r) = L(x) \forall x \in \{0,1\}^n$
		prove r* exists
		hardwire it into the circuit
		Proof: Let $r \leftarrow \{0,1\}^n$ be uniformly random and define $B_{x,r}$ to be the bad event that $C(x,r) \neq L(x)$
		Then by error reduction, Probability that r satisfies the claim (a good universal r* exists) is $$PR_r[\forall x C(x,r)=L(x)]=1-Pr_r[\exists x C(x,r) \neq L(x)] = $$ %insert image here

Theorem: (Sipser-Gacs-Lautemann)
$$BPP \subseteq \sum_2^P \cap \Pi_2^P$$
Proof:
Since BPP is closed under complement, we only show BPP \subseteq \sum_2^P Using error reduction, if L\in BPP then there is a polytime TM M such that $x \in L \leftrightarrow Pr_{{r = \{0,1\}}^{poly(n)}}[M(x,r)=L(x)] \geq 1-2^{-n}$
For each x \in \{0,1\}^n define the set S_x={r | M(x,r)=1} to be the set of coin tosses that cause M to accept x. Then $$ x \in L \rightarrow |S_x|/2^{poly(n)} \geq 1-2^{-n} $$ $$ x \notin L \rightarrow |S_x|/2^{poly(n)} \leq 2^{-n} $$
Goal: use 2 quantifiers to distinguish between the 2 cases
If x \in L, $\underline{\text{there exists}}$ a small number of a "additive shifts" of S_x whose union covers all of {0,1}^n
If x \notin L, then every small number of shifts fails to cover the whole space
 