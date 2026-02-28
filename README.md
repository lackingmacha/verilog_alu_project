# 🔧 Parameterized 16-Bit ALU in Verilog

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Status](https://img.shields.io/badge/Status-Verified%20%26%20Passing-brightgreen)
![Operations](https://img.shields.io/badge/Operations-12%20Core-orange)
![Bits](https://img.shields.io/badge/Width-16--bit%20Parameterized-purple)

A fully verified, parameterized Arithmetic Logic Unit (ALU) implemented
in Verilog, featuring 12 core operations and a robust self-checking
testbench with a behavioral reference model, directed corner-case tests,
and randomized verification.

------------------------------------------------------------------------

## 📋 Table of Contents

-   [Overview](#overview)
-   [Features](#features)
-   [Supported Operations](#supported-operations)
-   [Opcode Encoding](#opcode-encoding)
-   [Status Flags](#status-flags)
-   [Project Structure](#project-structure)
-   [Getting Started](#getting-started)
-   [Testbench & Verification](#testbench--verification)
-   [Design Details](#design-details)
-   [Next Steps](#next-steps)

------------------------------------------------------------------------

## Overview

This project implements a parameterized combinational Arithmetic Logic
Unit (ALU) in Verilog.\
The design supports configurable operand width through a synthesis-time
parameter (`W`, default = 16 bits).

The ALU performs arithmetic, logical, shift, rotate, and comparison
operations and generates five status flags (Z, S, C, V, P).

A self-checking testbench with a behavioral reference model validates
functional correctness using both directed edge-case testing and
randomized stimulus.

------------------------------------------------------------------------

## Features

-   ✅ **Parameterized design** --- configurable data width (`W`,
    default: 16-bit)
-   ✅ **12 core operations** --- arithmetic, logic, shift, rotate, and
    compare
-   ✅ **5 status flags** --- Zero, Sign, Carry, Overflow, Parity
-   ✅ **Self-checking testbench** with behavioral reference model
-   ✅ **Extensive directed corner-case testing**
-   ✅ **Randomized testing** for broad functional coverage
-   ✅ **Fully debugged and verified**

------------------------------------------------------------------------

## Supported Operations

  -----------------------------------------------------------------------
  Category                            Operations
  ----------------------------------- -----------------------------------
  Arithmetic                          Addition (ADD), Subtraction (SUB)

  Logic                               AND, OR, XOR, NOT

  Shift                               Logical Shift Left (LSL), Logical
                                      Shift Right (LSR), Arithmetic Shift
                                      Right (ASR)

  Rotate                              Rotate Left (ROL), Rotate Right
                                      (ROR)

  Compare                             Compare (CMP -- subtraction with
                                      flags update, result not
                                      architecturally stored)
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Opcode Encoding

  Opcode   Operation
  -------- -----------
  0000     ADD
  0001     SUB
  0010     AND
  0011     OR
  0100     XOR
  0101     NOT
  0110     LSL
  0111     LSR
  1000     ASR
  1001     ROL
  1010     ROR
  1011     CMP

------------------------------------------------------------------------

## Status Flags

  -----------------------------------------------------------------------
  Flag                    Description
  ----------------------- -----------------------------------------------
  **Zero (Z)**            Set when the result equals `0`

  **Sign (S)**            Mirrors the MSB of the result

  **Carry (C)**           For ADD: set on unsigned overflow.
                          `<br>`{=html} For SUB/CMP: set when no borrow
                          occurs (`x ≥ y`). `<br>`{=html} For
                          shifts/rotates: equals the last bit shifted
                          out.

  **Overflow (V)**        Set on signed arithmetic overflow (ADD/SUB/CMP
                          only)

  **Parity (P)**          Set when result contains even number of 1s
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## Project Structure

    alu_project/
    ├── rtl/
    │   └── alu.v              # Parameterized ALU RTL
    ├── tb/
    │   └── alu_tb.v           # Self-checking testbench with reference model
    └── README.md

------------------------------------------------------------------------

## Getting Started

### Prerequisites

-   Any Verilog simulator (e.g., Icarus Verilog, ModelSim, Vivado
    Simulator)
-   Optional: GTKWave for waveform viewing

### Simulation (Icarus Verilog Example)

``` bash
git clone https://github.com/<your-username>/alu-verilog.git
cd alu-verilog

iverilog -o alu_sim rtl/alu.v tb/alu_tb.v
vvp alu_sim
```

------------------------------------------------------------------------

## Changing the Data Width

In `rtl/alu.v`, modify:

``` verilog
parameter integer W = 16;
```

You may also adjust `OPW` if adding additional operations.

------------------------------------------------------------------------

## Testbench & Verification

The testbench follows a verification-first methodology and consists of:

### 1. Behavioral Reference Model

A pure behavioral Verilog model computes expected results and flags
independently of the DUT, enabling automatic comparison.

### 2. Directed Corner-Case Tests

Targeted test vectors cover: - Maximum and minimum values - Zero
results - Signed overflow boundaries - All-ones and single-bit
operands - Shift amounts of 0 and W−1

### 3. Randomized Testing

A constrained-random loop applies hundreds of random operand/opcode
combinations to uncover corner-case bugs.

All tests are self-checking. Any mismatch between DUT and reference
model immediately halts simulation with a descriptive error message.

------------------------------------------------------------------------

## Design Details

-   Fully combinational datapath (no clock)
-   Barrel-style shifting and rotation using bitwise operators
-   Explicit carry semantics for:
    -   Addition (unsigned carry-out)
    -   Subtraction (no-borrow detection)
    -   Shift/rotate (last bit shifted out)
-   Signed overflow detection for ADD/SUB/CMP
-   Parameterized opcode width (`OPW`)

------------------------------------------------------------------------

## Next Steps

-   [ ] FPGA Synthesis and timing analysis
-   [ ] Integrate into a simple CPU datapath
-   [ ] Add formal verification (SymbiYosys)
-   [ ] Wrap with AXI4-Lite interface
-   [ ] Add UART-controlled ALU interface

------------------------------------------------------------------------

## License

This project is open-source under the MIT License.

------------------------------------------------------------------------

*Built as a digital design and verification learning project.*
