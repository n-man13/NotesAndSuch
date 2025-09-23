# Task 1: Full Adder
## Part 1.1: Derive the logic for a 1-bit adder
### Truth Table:
|   CI   |   B   |   A   |  CO   |   S   |
| ------ | ----- | ----- | ----- | ----- |
|   0    |   0   |   0   |   0   |   0   |
|   0    |   0   |   1   |   0   |   1   |
|   0    |   1   |   0   |   0   |   1   |
|   0    |   1   |   1   |   1   |   0   |
|   1    |   0   |   0   |   0   |   1   |
|   1    |   0   |   1   |   1   |   0   |
|   1    |   1   |   0   |   1   |   0   |
|   1    |   1   |   1   |   1   |   1   |

### Boolean Logic:

#### Carry Over Bit:

$ CO = A B \bar{CI} + A \bar{B} CI + \bar{A}B CI + A B CI $

$ CO = A B( CI + \bar{CI}) + \bar{A} B CI + A \bar{B} CI = A B + \bar{A} B CI + A \bar{B} CI$

$ = A(\bar{B} CI + B) + \bar{A} B CI = A (CI + B) + \bar{A} B CI $

$ = A CI + A B +\bar{A} B CI = A B + CI(\bar{A} B + A) $

$ = A B + CI (B + A) = A B + B CI + A CI $

#### Sum Bit:

$ S = A \bar{B CI} + \bar{A} B \bar{CI} + \bar{A B} CI + A B CI $

$ = A \oplus B \oplus CI $


## Part 1.2: Implement the 1-bit adder
```Verilog
module FullAdder(input a, input b, input ci, output s, output co);
    /*
    Implement a full adder using verilog
    */
    /*
    using data flow modeling
    assign s = a ^ b ^ ci;
    assign co = (a & b) | (b & ci) | (a & ci);
    */
    wire tempSum;
    wire foo;
    wire bar;
    wire baz;
    wire quux;


    xor(temp, a, b);
    xor(s, temp, ci);

    and(foo, a, b);
    and(bar, b, ci);
    and(baz, a, ci);
    or(quux, foo, bar);
    or(co, baz, quux);

endmodule
```