import math

N = 8  # Change this to match your FFT size!
BITS = int(math.log2(N))

def float_to_q115_hex(val):
    """Converts a float between -1.0 and 1.0 to a 16-bit Q1.15 hex string."""
    q_val = int(round(val * 32768))
    # Clamp to prevent overflow
    if q_val > 32767: q_val = 32767
    if q_val < -32768: q_val = -32768
    # Convert to 16-bit Two's Complement Hex
    return f"{q_val & 0xFFFF:04X}"

def bit_reverse(val, bit_width):
    """Reverses the bits of an integer."""
    binary_str = f"{val:0{bit_width}b}"
    reversed_str = binary_str[::-1]
    return int(reversed_str, 2)

print(f"Generating RAM input for N={N}...")

# 1. Generate the natural-order test signal (0.5 * cosine wave)
x_real = [0.0] * N
x_imag = [0.0] * N

for n in range(N):
    # x_real[n] = n/N (for generating ramp input)
    x_real[n] = 0.5 * math.cos(2 * math.pi * n / N)
    x_imag[n] = 0.0

# 2. Scramble into Bit-Reversed Order and Write to File
with open("ram_init.mem", "w") as f_ram:
    for physical_address in range(N):
        # Find which natural index belongs at this physical memory address
        natural_index = bit_reverse(physical_address, BITS)
        
        val_real = x_real[natural_index]
        val_imag = x_imag[natural_index]
        
        hex_real = float_to_q115_hex(val_real)
        hex_imag = float_to_q115_hex(val_imag)
        
        # Write exactly as 32-bit hex: {Real(16), Imag(16)}
        f_ram.write(f"{hex_real}{hex_imag}\n")

print("Done! File 'ram_init.txt' created.")
