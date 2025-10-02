#lectureNotes 
Last time was NP reductions
$$\forall L \in NP, \leftrightarrow SAT \leftrightarrow 3SAT \leftrightarrow \text{independent set} \leftrightarrow \text{ vertex cover }$$
people prefer 3sat as the formula is neater than SAT
$$ \phi(x_1,x_2,...,x_n) \rightarrow (x_1 \lor \bar{x_2} \lor x_3) \land (x_2 \lor \bar{x_3} \lor x_4) \land (...\lor x_n) $$

different class of problems
$$ CoC = \{L : \bar{L} \in C\} $$
$$L \in \text{CoNP if }\exists \text{ }P(.), M\text{ deterministic polynomial time} 
$$
$$ \forall x \in L : \forall c \in \{0,1\}^{P(|x|)}, M(x,c)=1$$
$$ \forall x \notin L : \exists c \in \{0,1\}^{P(|x|)}, M(x,c)=0$$
$$\text{if }P=NP \implies EXP = NEXP$$
