Radix-2 Decimation-in-Time FFT Processor
Overview

This repository contains the RTL implementation of a scalable, parameterized Radix-2 Decimation-in-Time Fast Fourier Transform (DIT-FFT) processor. Designed in Verilog and synthesized using Xilinx Vivado, the architecture is tailored for efficient digital signal processing. The design leverages a custom hardware architecture featuring pipelined execution and fixed-point arithmetic to balance high computational throughput with resource efficiency.

Key Features
1. Parameterized Architecture: Fully scalable Radix-2 DIT-FFT algorithm, allowing for configurable point sizes based on system requirements.

2. Precision Fixed-Point Arithmetic: Robust numerical processing incorporating scaling, truncation, and saturation to maintain high precision while actively preventing integer overflow during successive computation stages.

3. Custom Hardware Datapath: * A dedicated Butterfly Unit for core decimation computations.

4. A Pipelined Complex Multiplier designed to maximize the clock frequency and maintain data throughput.

5. Advanced Memory & Control Logic: A centralized Finite State Machine (FSM) strictly controls data routing and handles complex addressing schemes for both the dual-port RAM (data storage) and the ROM (twiddle factors).

6. Automated Python Tooling: Includes auxiliary Python scripts to generate memory initialization data, streamlining the testing and verification process:

  A twiddle factor generator to populate the ROM.

  An input stimulus generator capable of creating customizable sinusoidal and ramp waveforms for the RAM.

Technology Stack
-> Hardware Description Language: Verilog

-> Synthesis & Simulation: Xilinx Vivado

-> Scripting & Automation: Python
