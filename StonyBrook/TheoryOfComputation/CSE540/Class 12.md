#lectureNotes 
Polynomial Hierarchy
Chapter 5
exact independent set - is there a <G,K>: largest independent set is exactly size k
1. check there is an independent set of size k
2. all sets of size >k are not in independent set
definition:
$$\sum^P_2 \text{is the class of all languanges with a polytime TM M and polynomial q such that } \ x \in L \leftrightarrow \exists u \in [0,1]^{q(|x|)} \forall v \in [0,1]^{q(|x|)} M(u,v)=1 $$
$$ \sum_i^P if \exists \text{ TM M (polytime) and polynomial q such that }  $$


$$ \text{PH} = \bigcup_i \sum_i^P $$
Collapse Theorem: * * * * * * * * Very Important * * * * * * * * * 
1. for every i >=1, if \sum_i^P =\product_i^P then PH collapses to \sum_i^P 
2. if P=NP then PH = P
PROOF:
by induction
base case: $$\sum_1^P = \prod_1^P ; P = NP = CoNP$$
Assume true for i-1 level $$ \sum_{i-1}^P = \prod_{i-1}^P $$$$L \in \sum_i^P $$

Alternating Time def(5.7)



$$AP = \bigcup_c ATIME(n^c) $$
Theorem: AP = PSPACE
Proof:
