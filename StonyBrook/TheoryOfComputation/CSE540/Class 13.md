#lectureNotes 
Review of last class:
$$ PH = \bigcup_i \sum_i^P $$
$$ PH \subset AP = PSPACE $$
$$\sum_i TIME \text{is the set of languages accepted by a T(n)-time ATM whose initial state is labeled }\exists \text{ and alternates at most i-1 times}$$
New:
Oracles and time-space tradeoffs

Def: for two functions S,T languages, let TISP(T(n),S(n)) be the set of languages decided by TM M in at most O(T(|x|)) steps and uses O(S(|x|)) space
	We will show that NTIME(n) \not \subsetequal TISP(n^1.2, n^0.2)
	Claim (5.14.1): TISP(n^12, n^2) \subsetequals \sum_2 Time(n^8)
	Proof:
		$ \text{Let L be decided by a TM M using }n^12\text{ time and using }n^2\text{ space. for each x } \in \{0,1\}^*, consider G_{M,x} $
		Since M runs in $n^{12}$ time, x is in L $iff \exists$ a path of length $n^12$ in this graph
		There is such a path (length $n^{12}$) iff $\exists n^6$ configurations such that $C_0 = C_{start}$ then $C_{n^6}$ is accepting and for every i $\in [n^6]$ the configuration $C_i$ is computed from $C_{i-1}$ in $n^6$ steps
		Before: $C_1 \rightarrow C_2 \rightarrow C_3 \rightarrow ... \rightarrow C_{n^12}$
		After: $[C_1 \rightarrow C_2 \rightarrow ... \rightarrow C_{n^6}]C_1 \rightarrow ... \rightarrow [...]_{C_{n^6}}$
		Things to check:
		1. Existential witness decidable in $\leq O(n^8)$ bits
		2. Universal check $C_1, ... ,C_{n^6} in O(n^8)$ time
	Claim(5.14.2): Suppose $NTIME(n) \subseteq DTIME(n^{1.2})$ then $\sum_2 TIME(n^8) \subseteq NTIME(n^{9.6})$
	Proof:
		Let $L \in \sum_2 TIME(n^8) L \in \sum_2 TIME(n^8) iff \exists TM$ M running in O(n^8) time such that $x \in L \leftrightarrow \exists w \in \{0,1\}^{|x|^8} \forall v\in \{0,1\}^{|x|^8} M(x,w,v)=1$
		// negate universal statement
		$\exists u \forall v M(x,u,v) =1 \leftrightarrow \exists u -(\exists v M(x,u,v)=0)$
		There is a deterministic algorigthm D that on inputs x,u with |x|=n runs in time $O(n^8)^{1.2} = O(n^9.6)$ time
		$D(x,u) = 1 \leftrightarrow \exists v M(x,u,v)=0$
		So $x\in L \leftrightarrow \exists U D(x,u) = 0$
			this is an NP problem since NTIME(n) \subset DTIME(n^{1.2})

for every $i \leq 2, \sum_i^P = NP^{\sum_{i-1}SAT}$ where $NP^{\sum_{i-1}SAT}$ denotes the set of languages decided by poly-time NDTMs with access to the oracle $\sum_{i-1}SAT$ -- BLACK BOX that does SAT for us
we show \sum_2^P = NP^{SAT} let L \in \sum_2^P then x \in L \leftrightarrow \exists u \in \{0,1\}

suppose L \in NP^{SAT}; decidable by a polytime NDTM N with SAT oracle access. If x \in L there is a sequence of queries q_{1,2,...,q_m} and answers to the queries a_1,...,a_k such that on input x, if N uses q_1,...,q_m and receives a as the answer to its query. L must reach its accepting state and all answers are correct.
x \in L iff \exists queries and answers 
\phi_i denote the ith query that N makes to the oracle when executing x with queries and answers, then all answers are correct \leftrightarrow if a_i = 1 then \exists u_i