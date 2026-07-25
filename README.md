# Radix-2 Decimation-in-Time FFT Processor

## 🚀 Project Overview

This project implements a fully synthesizable, parameterized **Radix-2 Decimation-in-Time Fast Fourier Transform (DIT-FFT)** processor using **Verilog**. The system is tailored for efficient digital signal processing, demonstrating high computational throughput and resource efficiency. 

Designed for FPGA implementation (Xilinx Vivado), this project showcases advanced hardware architecture concepts including fixed-point arithmetic, pipelined execution, complex memory addressing schemes, and automated test-data generation.

## 🏗️ System Architecture

The data flows through a synchronized hardware datapath driven by a central controller:

`Input Stimulus (RAM)` ➔ `Control FSM` ➔  `Pipelined Multiplier` ➔ `Butterfly Unit`   ➔ `Output RAM`

### 1. Finite State Machine (FSM) Controller
* Acts as the brain of the FFT processor.
* **Key Feature:** Manages strict execution timing and complex address generation for both the dual-port RAM (read/write data) and the twiddle factor ROM.
* Ensures proper routing of data through the pipelined computation stages.

### 2. Butterfly Unit
* The core computational engine for the Decimation-in-Time algorithm.
* Executes the basic add/subtract operations required for the radix-2 cross-computations.

### 3. Pipelined Complex Multiplier
* Handles the complex multiplication of data points with twiddle factors.
* **Key Feature:** Pipelined architecture significantly maximizes the maximum clock frequency (Fmax) and maintains high data throughput without causing timing bottlenecks.

### 4. Precision Fixed-Point Arithmetic Logic
* Replaces floating-point math with robust fixed-point numerical processing.
* Actively prevents integer overflow during successive FFT stages by incorporating automatic scaling, truncation, and saturation logic.

### 5. Automated Python Tooling
* Auxiliary Python scripts designed to streamline hardware verification.
* Generates initialization files (`.mem`) including a twiddle factor lookup table for the ROM and customizable sinusoidal/ramp waveforms to load into the Input RAM.

---

## 🛠️ Technical Features

* **Algorithm:** Radix-2 Decimation-in-Time FFT.
* **Language:** Verilog HDL & Python.
* **Parameterization:** Scalable architecture allowing for easily configurable FFT point sizes (N) based on target system requirements.
* **Memory Architecture:** Dual-port RAM for continuous read/write data storage and dedicated ROM for twiddle factor constants.
* **Synthesis Ready:** Designed with proper clocking and logic structures optimized for Xilinx FPGA architectures.

## 📊 Simulation & Verification

The design has been verified using **Xilinx Vivado Simulator (XSim)** alongside Python-generated test vectors.

**Test Case Scenarios:**

1. **Memory Initialization:** Verified that Python-generated `.mem` files correctly load twiddle factors and input waveforms into ROM/RAM.
2. **Datapath Accuracy:** Validated the pipelined multiplier and butterfly unit outputs against theoretical FFT calculations.
3. **Overflow Handling:** Confirmed that scaling and saturation logic successfully maintains precision and prevents data wrapping during high-amplitude inputs.
4. **Addressing Logic:** Verified the FSM correctly computes the bit-reversed addressing required for the DIT-FFT stages.

*Note: Data integrity and fixed-point precision were analyzed by comparing the Verilog simulation output waveforms with software-computed FFT results in Python.*

## 📂 File Structure

* `control_fsm.v` - Centralized state machine and address generator.
* `butterfly_unit.v` - Radix-2 addition/subtraction computation block.
* `complex_multiplier.v` - Pipelined complex multiplier.
* `dual_port_ram.v` - Data storage for incoming and intermediate values.
* `twiddle_rom.v` - Read-only memory for pre-computed phase factors.
* `top_module.v` - Top-level wrapper instantiating the datapath and controller.
* `FFT_testbench.v` - Simulation testbench for full system verification.
* `twiddle_generator.py` - Generates ROM initialization data.
* `input_generator.py` - Generates sine/ramp wave RAM input data.

## 🔧 Tools Used

* **IDE:** Xilinx Vivado 
* **Simulation:** Vivado XSim
* **Scripting:** Python (NumPy, Matplotlib for verification)

---

## 📜 How to Run

1. Clone the repository to your local machine.
2. Run the Python scripts in the `scripts/` folder to generate the required `.mem` initialization files.
3. Open **Vivado** and create a generic RTL project.
4. Add all Verilog files as Design Sources.
5. Add the generated `.mem` files to the project as memory initialization files.
6. Add `FFT_testbench.v` as a Simulation Source and set it as the top module.
7. Run **Behavioral Simulation** to observe the FFT computation in the waveform viewer.
8. Change the parameter values in the python scripts and the verilog code to get the desired number of points in FFT
