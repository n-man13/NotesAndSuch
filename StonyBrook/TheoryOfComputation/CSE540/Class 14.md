#lectureNotes 
Review of previous class:
We can write $\forall i \leq 2, \sum_i^p=NP^{\sum_{i-1}SAT}$ 
$\sum_2^P=NP^{SAT}=NP^{NP}$
$\sum_i^P=NP^{NP^{...^{NP}}}$ i-1 many NP

https://cseweb.ucsd.edu/classes/fa21/cse200-a/notes/6-boolean%20circuits.pdf
Boolean Circuits
fan-in vs fan-out per gate = AND, OR fan-in 2 -- 2 inputs

Denote a circuit by C and it's evaluation on x \in {0,1}^*
Size of a circuit is number of gates - |C(x)| or |C|

Def:
Let $T: \mathbb{N} \rightarrow \mathbb{N}$. A T(n)-size circuit family is a sequence $\{C_n\}_{n \in \mathbb{N}}$ of boolean circuits where C_n has n inputs and a single output and its size is |C_n|\leq T(n) \forall n
We say a language L \in SIZE(T(n)) if there exists a T(n)-size circuit family {C_n}_{n \in \nat} \suchthat \forall x \in {0,1}^n, x\in L \leftrightarrow C_n(x) = 1
Circuits are non-uniform - Verifier depends on size of inputs

Ex: Language {1^n: n \in \mathbb{N}} can be decided by a linear circuit family - solved with just a bunch of and gates

Def: P/Poly is a class of languages that are decidable by poly-sized circuit families. $P/Poly = \bigcup_C SIZE(n^C)$ 

Ex: UHALT (unary halting problem) = {1^n: n's binary expansion encodes a pair <M,x> such that M halts on input x} therefore P/Poly contains some undecidable problems

Def: (Turing machines with advice) Let T $a : \mathbb{N} \rightarrow \mathbb{N}. \text{the class of languages deciable by time-N(n) Turing machines with a(n) bits of advice denoted DTIME(T(n))/a(n) contains every }L \suchthat \every a sequence {\alpha_n}_{n\in \mathbb{N}} of strings with \alpha_n \in \{0,1\}^{a(n)} and a TM M satisfying M(x,\alpha_n)=1 \leftrightarrow x\in L \forall x \in \{0,1\}^n where on (x,\alpha_n) MM runs for at most O(T(n)) Time$ 
Theorem: $P/Poly = \bigcup_{C,d \geq 1} DTIME(n^C)/n^d$
Proof:
	L \in P/Poly L can be decided by a poly-size circuit family $\{C_n\}_{n \in \mathbb{N}}$ 
	the advice is the description of the circuit
	proves P/Poly \subset \bigcupDTIME

	Let $L \in DTIME(n^C)/n^d$ There exists a circuit that computes $M(x,\alpha)$
	$Comes from a theorem $$C \subseteq P/Poly$$

Theorem Karp-Lipton: If $NP \subset \text{ P/Poly then }PH = \sum_2$ 
