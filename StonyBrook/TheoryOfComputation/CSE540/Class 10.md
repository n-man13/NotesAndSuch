#lectureNotes 
$$L \in NL ,\text{logspace } M, P(.) x\in L \exists c \in \{0,1\}^{P(n)}
$$$$M(x,c) = 1$$
This proves it is in NL

Now for NL Hard
$$\forall L \in NL; L \leq_l Reach(G,s,t)$$
Consider the adjacency matrix of the graph

Certify u is not in C_i given |C_i|
list of certificates that $$ \forall u, u \in C_i (\text{ascending}) $$
each certificate is valid, vertex u is larger than previous vertex, that no certificate is provided for u, total number of certificate is |C_i|
