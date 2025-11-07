# Task 1: Develop a Five-Stage Pipelined MIPS Processor
Implement a five-stage pipeline following the canonical MIPS design with the following stages:
1. Instruction Fetch (IF)
2. Instruction Decode / Register Fetch (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

You may reuse and adapt your modules from the single-cycle processor (ALU, Control Unit, Register File, Memory, etc.), but modify the datapath and control logic to support pipelined execution.

Here is the image we went through in class with finalized pipeline control
![alt text](./images/PipelinedProcessor.png)


\begin{table}[h!]
\centering
\caption{Effect of Hazard Detection on MIPS Pipeline Execution (No Data Forwarding)}
\begin{tabular}{|p{4cm}|p{5.5cm}|p{5.5cm}|}
\hline
\textbf{Aspect} & \textbf{Hazard Detection ON} & \textbf{Hazard Detection OFF} \\ \hline

\textbf{Pipeline Behavior} &
Hazard detection unit inserts stalls whenever an instruction depends on a previous result not yet written back. &
No stalls are inserted; instructions proceed without waiting for previous results. \\ \hline

\textbf{Handling of Data Hazards} &
RAW hazards are detected and resolved by inserting pipeline bubbles. &
RAW hazards are ignored; dependent instructions use stale register values. \\ \hline

\textbf{Performance} &
Slower execution due to multiple stall cycles between dependent instructions. &
Faster apparent execution since no stalls occur, but results are incorrect. \\ \hline

\textbf{Correctness of Results} &
Program executes correctly; all data dependencies are respected. &
Program produces incorrect results due to premature operand reads. \\ \hline

\textbf{Example Outcome (Registers)} &
\begin{tabular}[c]{@{}l@{}}
\$t0 = 8 \\
\$t1 = 15 \\
\$t2 = 15 \\
\$t3 = 30 \\
\$t4 = 15 \\
\$s0 = 45 \\
Mem[8] = 15
\end{tabular} &
\begin{tabular}[c]{@{}l@{}}
\$t0 = 8 \\
\$t1 = 15 \\
\$t2 = 0 \\
\$t3 = 15 \\
\$t4 = 0 \\
\$s0 = 15 \\
Mem[8] = 0
\end{tabular} \\ \hline

\textbf{Overall Summary} &
Correct but slow due to inserted stalls. &
Fast but incorrect due to missing hazard handling. \\ \hline

\end{tabular}
\end{table}
