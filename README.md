# ALU Design Project

## Introduction

This project implements a **parameterized Arithmetic Logic Unit (ALU)** that supports:
- Arithmetic operations (add, sub, inc, dec, etc.)
- Logical operations (AND, OR, XOR, etc.)
- Shift and rotate operations with mode control
- Signed/unsigned arithmetic with overflow detection
- Carry-in handling and comparator outputs

The ALU is designed to be:
- **Synthesizable** for hardware implementation
- **Verifiable** using a modular, self-checking testbench

---

## Objectives

-  Design a **flexible and parameterized ALU** supporting a wide range of arithmetic and logical operations.
-  Implement **pipelined execution**, supporting 2 or 3 clock cycle latency based on operation type.
-  Integrate **signed/unsigned arithmetic**, **input validation**, and **error signaling**.
-  Build a **reusable and scalable testbench** with:
  - Driver  
  - Monitor  
  - Scoreboard
-  Validate correctness using a **stimulus-response comparison** mechanism.
-  Generate **automated functional reports** for verification results.

## ALU Operation Command Table

| Command Code | Operation Name         | Mode (MODE) | Description                                      |
| ------------ | ---------------------- | ----------- | ------------------------------------------------ |
| `4'b0000`    | `ADD / AND`            | 1 / 0       | Addition in arithmetic mode, AND in logic mode   |
| `4'b0001`    | `SUB / NAND`           | 1 / 0       | Subtraction or NAND                              |
| `4'b0010`    | `ADD_CIN / OR`         | 1 / 0       | Addition with carry or OR                        |
| `4'b0011`    | `SUB_CIN / NOR`        | 1 / 0       | Subtraction with carry or NOR                    |
| `4'b0100`    | `INC_A / XOR`          | 1 / 0       | Increment A or XOR                               |
| `4'b0101`    | `DEC_A / XNOR`         | 1 / 0       | Decrement A or XNOR                              |
| `4'b0110`    | `INC_B / NOT_A`        | 1 / 0       | Increment B or NOT A                             |
| `4'b0111`    | `DEC_B / NOT_B`        | 1 / 0       | Decrement B or NOT B                             |
| `4'b1000`    | `CMP / SHR1_A`         | 1 / 0       | Compare A & B (signed), Shift Right A            |
| `4'b1001`    | `SHL1_A / INC1_MUL`    | 0 / 1       | Shift Left A / (OPA+1)\*(OPB+1)                  |
| `4'b1010`    | `SHR1_B / SHL1_A_MULB` | 0 / 1       | Shift Right B / (OPA<<1)\*OPB                    |
| `4'b1011`    | `SHL1_B / S_UNS_ADD`   | 0 / 1       | Shift Left B / Signed-Unsigned Addition          |
| `4'b1100`    | `ROL_A_B / S_UNS_SUB`  | 0 / 1       | Rotate Left A by B / Signed-Unsigned Subtraction |
| `4'b1101`    | `ROR_A_B`              | 0           | Rotate Right A by B                              |

##  Working Methodology

The ALU (Arithmetic Logic Unit) is a parameterized Verilog module designed to perform a wide range of arithmetic and logical operations based on input control signals. The module operates in a clocked and pipelined fashion, ensuring proper sequencing of multi-cycle operations. Here's a step-by-step overview of how it works:

1. **Input Latching and Validation**  
   - The ALU accepts operands `OPA` and `OPB`, a command `CMD`, mode `MODE`, and a 2-bit input validity signal `INP_VALID`.
   - Only when valid input combinations are received (e.g., `INP_VALID == 2'b11`), the operation proceeds.

2. **Mode-Based Operation Selection**  
   - The `MODE` signal selects between **Arithmetic** (`MODE = 1`) and **Logical/Shift** (`MODE = 0`) operations.
   - Each operation is identified by a specific command (`CMD`) value.

3. **Operation Decoding & Execution**  
   - Arithmetic operations include: `ADD`, `SUB`, `INC_A`, `DEC_B`, etc.
   - Logical operations include: `AND`, `OR`, `XOR`, `NOT_A`, etc.
   - Special operations like shift/rotate (`SHL1_A`, `ROR_A_B`) and signed math (`S_UNS_ADD`, `S_UNS_SUB`) are supported.
   - Multiplication operations (`INC1_MUL`, `SHL1_A_MULB`) are executed if enabled.

4. **Pipelining**  
   - A 3-stage pipeline (`VALID_PIPE`) is used to delay and sequence data for multi-cycle operations (e.g., multiplication or comparison).
   - Each valid input progresses through this pipeline until the result is ready.

5. **Result Generation**  
   - The output `RES` holds the final result.
   - Status flags like `OFLOW` (overflow), `COUT` (carry-out), `ERR` (input error), and comparison flags `G`, `L`, `E` are computed based on operation type.

6. **Error Handling**  
   - If the input validity is incorrect or an undefined `CMD` is provided, the ALU sets `ERR = 1` and zeroes the result.


## Future Improvements

- **Expand Operation Set**  
  Add more advanced arithmetic functions such as division, modulus, or floating-point operations using additional `CMD` values.

---

> 📌 This project aims to be educational and practically useful for RTL designers focusing on modular, pipelined digital systems.
