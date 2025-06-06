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

---

> 📌 This project aims to be educational and practically useful for RTL designers focusing on modular, pipelined digital systems.
