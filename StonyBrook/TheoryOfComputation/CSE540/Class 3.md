#lectureNotes 
Scribing notes

Overview}
This lecture introduces the concept of \textbf{Universal Turing Machines}. 
As a Turing Machine is a single program that runs a single algorithm, Universal Turing Machine takes the description of a Turing Machine and the input to behave as said Turing Machine. 
$U(M,x)$ where M is the description of what states should be set up depending on the input and what to do in that state, also known as a $\delta$ table.
Universal Turing Machines are the basis of all general-purpose computers of today.

\section {Halting Problem}
If you ask U to run M and it has not completed after some time. Should you stop the program after an hour? after a day?
Instead of outputting M(x), $U_{\text{halt}}$ would output 1 if M stops (ever) on x, else outputs 0
This is impossible for every Turing Machine
A paradox happens when you feed description D into machine D.
\begin{figure}[]
    \centering
    \includegraphics[width=0.5\linewidth]{scribe notes/lecture 3/images/ParadoxUTM.jpg}
    \caption{Universal Turing Machine that when fed with its own description as the input, will create a paradox}
\end{figure}
More on this problem in lecture 09/10/2025

\section {Time Limit}
As there are some inputs that a Turing Machine cannot solve, we need to be able to implement a time limit.
We can add a clock that increments each operation of the machine
$U_{\text{T(n)}}(M,x)$ but this timing function T cannot take longer than T(n) time to compute on length n
All formulas we have seen so far except for the paradoxes are \textbf{Time Constructible}
$$f(x)=y;  f:x \rightarrow y;  f:\{0,1\}^n \rightarrow \{0,1\};  M_f \{0,1\}^n \rightarrow \in \{0,1\}$$
$$\text{M computes f if and only if } \forall x \in \{0,1\}^n  M(x)=f(x)$$
Needs to compute within time limit

DTime
DTIME(T(n)) is a class of problems/functions such that for every f in DTIME(T(n)) there exists a deterministic Turing machine M that computes f in time T(n); D stands for deterministic
Note: always assume T(n) is time constructible unless otherwise stated
$$⋃_(c>0)▒〖DTIME(n^c )=P〗$$
P is for polynomial
Once you find that it is in P, it can generally be simplified to $n^4$ or less
$$O(c^n )\neq P; O(n^{log(⁡n)}  ) \neq P$$
True complexity problems in this
Non-deterministic Turing machine examples: guesses the next step. Each state transition is made by a guess between 2 options. This allows for a lucky path to get to the end result.
\begin{figure}
    \centering
    \includegraphics[width=0.5\linewidth]{scribe notes/lecture 3/images/DeterministicStateMachines.jpg}
    \caption{Deterministic Finite State Machine vs Non-Deterministic Finite State Machine}
\end{figure}