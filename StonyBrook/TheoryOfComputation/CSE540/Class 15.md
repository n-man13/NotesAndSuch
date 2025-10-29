#lectureNotes 
BPP class

we dont know if bpp is in p. we think so, but if bpp_{oracle} separated p_{oracle}

Def:
A probabilistic turing machine (PTM) is a TM with 2 transition functions S_0, S-1 To execute a PTM M on x, apply S_0 with probability 1/2 and S_1 with probability 1/2 at each step. For $T: \mathbb{N} \rightarrow \mathbb{N}$ we say the M runs in T(n) time if for any input M halts after at most T(|x|) steps

Def BPP
For $T: \mathbb{N} \rightarrow \mathbb{N}$ we let BPTIME(T(n)) be the class of languages decided by PTMs in O(T(n)) time and define $BPP=\bigcup_C BPTIME(n^C)$ 
Def Alternative
L is in BPP if $\exists$ polytime TM M and poly $P: \mathbb(N) \rightarrow \mathbb(N)$ such that  $\forall x \in \{0,1\}^*$ BPP has 2 sided errors, false positive and false negative with at most 1/3 chance
Completeness = always positive when given a positive value


Def RP
RTIME contains every language L for which $\exists$ a PTM M running in time T(n) such that 
$$x \in L \leftrightarrow Pr[M(x) = 1] \geq 2/3$$
$$ x \notin L \leftrightarrow Pr[M(x)=1]=0$$
Define RP = $\bigcup_{C>0}RTIME(n^c)$ 

For a PTM M on input x, we define the random variable $T_{M,x}$ to be the running time of M on x. So $Pr[T_{M,x}=T]=P$ if with probability P it will halt within T steps. We say M has **expected running time** $T(n) if \mathbb{E}[T_{M,x}]$ is at most $T(|x|) \forall x \in \{0,1\}^*$ 

Def ZPP
ZTIME(T(n)) contains all languages with a machine M that runs in **expected time** O(T(n)) such that it exactly produces L(x) Let ZPP = $\bigcup_{c>0} ZTIME(n^c)$

Def ZPP (in expected time)
$$x \in L \leftrightarrow Pr[M(x)=1]=1$$
$$x \notin L \leftrightarrow Pr[M(x)=1]=0$$

Theorem
$$ZPP = RP \cap CoRP$$
L \in ZPP L is decided by an zero error PTM M in expected time P(n). First $L \in RP$ by algorithm:
1. Run M on x for 3P(|x|) steps
2. if M accepts, accept. If M rejects or does not halt, reject
Runtime: Always halts after O(P(n)) steps.
Correctness: Suppose x ]in L then by assumption $\mathbb{E}[T_{M,x}] \leq P(|x|)$. From Markovs inequality, $Pr[T_{M,x} \geq 3P(|X)] \leq 1/3$ 
$L \in CoRP$ is the same as this algorithm, just the negative
$L \in RP \cap CoRP$ L is decided by P(n) time RP machine M_1 and CoRP machine M_2
Algorithm:
	1. Run M_1 on x. If it accepts, accept
	2. Run M_2 on x. If it rejects, reject

Error Reduction in BPP:
idea: Why did we choose 2/3 for BPP definition?
Not necessary, can replace with any constant > 1/2 like $1/2 + 1/poly(n) or 1-2^{-poly(n)}$
Theorem: (Error Reduction BPP) suppose M is a PTM running in time T(n) such that
$x \in L \leftrightarrow Pr[M(x) = 1] \geq 1/2+\epsilon$
$x \notin L \leftrightarrow Pr[M(x) = 1] \geq 1/2+\epsilon$ 
$\forall x, Pr[M(X)=L(x)] \geq 1/2 + \epsilon$
then there exists a PTM M' running in time $O(log(1/\delta)/\epsilon^2 T(n))$  such that $Pr[M'(x) = L(x)] \leq 1-\delta$
Proof:
On input x:
1. Run M(x) independently K = $log(2/\delta)/\epsilon^2$ times producing outputs b_1, ... b_k
2. Take a majority vote of the outputs and Define the random variables: X_i = {1, b_i=L(x), else 0}
Algorithm makes an error iff x< k/2 where $x = \sum_{i=1}^k x_i$ 
Each x_i individually takes value 1 with some advantage, $\mathbb{E} [x_i] \geq 1/2+\epsilon, so \mathbb{E} [x] \geq k/2+\epsilon k$
$$Pr[M'(x)\neq L(x)] = Pr[x < k/2]$$
$$\leq Pr[|x-\mathbb{E}[x]|> \epsilon k]$$
$$ \leq 2exp(-2(\epsilon k)^2/k) \leq \delta $$
