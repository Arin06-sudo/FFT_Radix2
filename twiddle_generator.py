import numpy as np

N = 8         # FFT size
W_WIDTH = 16   # 16-bit fixed-point (Q15) for real and imag

with open("twiddle.mem", "w") as f:
    # Only need N/2 factors due to symmetry
    for k in range(N // 2):
        real = np.cos(-2 * np.pi * k / N)
        imag = np.sin(-2 * np.pi * k / N)
        
        # Convert to Q15 fixed-point
        real_q15 = int(real * ((1 << (W_WIDTH - 1)) - 1))
        imag_q15 = int(imag * ((1 << (W_WIDTH - 1)) - 1))
        
        # Pack into a 32-bit hex string [Real (16) | Imag (16)]
        val = (real_q15 & 0xFFFF) << 16 | (imag_q15 & 0xFFFF)
        f.write(f"{val:08X}\n")
