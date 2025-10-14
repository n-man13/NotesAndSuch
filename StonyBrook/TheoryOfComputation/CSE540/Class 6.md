#lectureNotes 
Scribing Notes

\documentclass[11pt]{article}

% Packages
\usepackage{amsmath, amssymb, amsthm}
\usepackage{enumitem}
\usepackage{fancyhdr}
\usepackage{tcolorbox}

% Title box
\newtcolorbox{mybox}{
  colback=gray!10, 
  colframe=black,
  boxrule=1.5pt,
  arc=5pt,
  left=6pt,
  right=6pt,
  top=6pt,
  bottom=6pt
}

% Theorem environment
\newtheorem{definition}{Definition}
\setlist{itemsep=0.3em, topsep=0.1em}

\begin{document}

\begin{mybox}
\textbf{Course:}CSE 540 – Graduate Theory of Computation – Fall 2025 \\[0.3em]
\textbf{Instructor:} Prof. Supartha Podder \\[0.3em]
\textbf{Lecture:} 09/17/2025 \\[0.3em]
\textbf{Scribe:} Nikhil Shah
\end{mybox}
\vspace{0.5em}   

\section{Overview}
This lecture is about the concept of NP and how to describe such problems. We also touched on the Cook-Levin Theorem and Satisfiability in NPComplete

\section{Key Definitions}

\begin{definition}[NP]
    NP is the class of languages where
    $$L\in \text{ NP if }\exists \text{ polynomial } p(.), \exists M_L (\text{ deterministic, run in q(n)time })$$
    $$\forall x \in L ;\exists c \in {0,1}^P(n) ;M_L (x,c)=1$$
    $$\forall x \notin L;\forall c \in {0,1}^P(n) ;M_L (x,c)=0$$
\end{definition}

\begin{definition}[EXP Class]
    EXP class is the class of languages where 
    $$ \bigcup _{c>0} DTIME(c^n ) $$
\end{definition}

\begin{definition}[Configuration Graph]
    Current input, entire worktape content, and state has defined next state
\end{definition}

\begin{definition}[NP Alternative]
    $$L\in \text{ NTIME }(T(n));T:\mathbf{N} \rightarrow \mathbf{N}$$
    $$\exists \text{ const c such that } \forall \text{ Non-Deterministic Turing Machine }N$$
    $$N \text{ runs for at most }c*T(n) \text{ times and }$$ 
    $$x \in L;|x|=n$$
    $$x \in L \iff N(x)=1$$
\end{definition}

\begin{definition}[Karp Reduction]
Karp Reduction is a form of Polynomial Transformation that allows solving one problem by solving a different but related problem.
    $$L_A \leq _P L_B$$
    $$x \in L_A \rightarrow ^{f(x) \rightarrow y} y\in L_B$$
    $$x \notin L_A \rightarrow ^{f(x) \rightarrow y}  y \notin L_B$$
    Where f can be run in polynomial time P
\end{definition}

\begin{definition}[NPComplete]
    NPComplete = NPHard in NP
\end{definition}

\section{NP Definition}
Both definitions are intuitively the same, just with an extra certificate tape.
$$\text{NP}=\bigcup_{c>0} \text{ NDTIME}(n^c)$$

NP might collapse to P, EXP and NP might be the same, but EXP and P are definitely different.


\section{SAT}
Satisfiability
$$SAT \phi (x_1,x_2,...,x_n )- \land (\lor (x_1, \bar{x_2},...,x_n)$$
$$\phi (x_1,x_2,x_3 ):(x_1 \lor \bar{ x_2 }) \land (x_2 \lor \bar{x_3})$$
Number of clauses = m, number of variables = n, then size of formula is m*n

$$SAT \leq 3SAT$$
$$(x_1 \lor x_2 \lor x_3... \lor x_k )$$
$$(x_1 \lor x_2 \lor y_1 ) \land (\bar{y_1}  \lor x_3 ... \lor x_k )$$
$$(x_1 \lor x_2 \lor y_1 ) \land (\bar{y_1} \lor x_3 \lor y_2 )\land (\bar{y_2} \lor x_4…\lor x_k )$$
$$\text{And continue until you reach }y_k$$
We will cover Cook-Levin Theorem that established the SAT formula in a later class

\end{document}