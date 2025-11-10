import ast
import os
from collections import defaultdict

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap


# Function to determine if a triple is proven by the theorems in the PDF
def proven_by_theorem(a, b, n):
    # Ensure valid inputs: 1 < k <= m < n
    if not (1 < a < n and 1 < b < n):
        return None
    
    k = min(a, b)
    m = max(a, b)
    
    # Skip invalid generator indices
    if k < 2 or m >= n or k >= m:
        return None
    
    # Special case: Corollary 5 (Big-3 flips) - {rn, r_{n-1}, r_{n-2}}
    if k == n-2 and m == n-1 and n >= 4:
        return True
    
    # Theorem 1: k = 2
    if k == 2 and n >= 4:
        if n % 2 == 0:  # even n
            return m == n-1
        else:  # odd n
            r = n % 3
            if r == 0 or r == 2:  # n ≡ 0 or 2 mod 3
                return m in (n-1, n-2)
            elif r == 1:  # n ≡ 1 mod 3
                return m in (n-3, n-2, n-1)
    
    # Theorem 2: k = 3
    if k == 3 and n >= 5 and m > 3:
        if n % 2 == 0:  # even n
            return m == n-2
        else:  # odd n
            r6 = n % 6
            if r6 == 3:  # n ≡ 3 mod 6
                return m == n-1
            elif r6 == 1 or r6 == 5:  # n ≡ 1 or 5 mod 6
                return m in (n-3, n-1)
            else:
                return False
    
    # Theorem 3: m = n-1 and n even
    if m == n-1 and n >= 4 and n % 2 == 0:
        return True
    
    # Theorem 4: m = n-2 with conditions
    if m == n-2 and n >= 7:
        if k > 3 and k < n-2 and (n % 2) != (k % 2):
            return True
    
    # Non-generating case 1: n >= 10 and l > 2k+1 (where l = n-m)
    l = n - m
    if n >= 10 and l > 2*k + 1:
        return False
    
    # Non-generating case 2: n >= 6, l >= k+1, and l divides n+1
    if n >= 6 and l >= k + 1 and (n + 1) % l == 0:
        return False
    
    return None

# Read and parse the data file
data = []
file_path = 'nohup.out'

with open(file_path, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = ast.literal_eval(line)
            if isinstance(entry, tuple) and len(entry) == 4:
                a, b, n, I = entry
                if 1 < a < n and 1 < b < n:  # Only valid generator indices
                    data.append((a, b, n, I))
        except Exception as e:
            print(f"Skipping line due to error: {line} | Error: {e}")

# Group data by n
data_by_n = defaultdict(list)
for (a, b, n, I) in data:
    data_by_n[n].append((a, b, I))

# Task 3: Grid plots for each n with 4-color scheme
output_dir = 'grid_plots_colored'
os.makedirs(output_dir, exist_ok=True)

# Define colormap: [light red, white, blue, black]
colors = ['lightcoral', 'white', 'blue', 'black']
cmap = ListedColormap(colors)
bounds = [-0.5, 0.5, 1.5, 2.5, 3.5]
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

# Only process n from 2 to 100 that exist in data
n_values = sorted(set(n for (_, _, n, _) in data if 2 <= n <= 100))

for n in n_values:
    # Create matrix to store computation results (I values)
    I_matrix = np.full((n, n), -1, dtype=int)
    
    # Fill I_matrix with computation results
    if n in data_by_n:
        for (a, b, I) in data_by_n[n]:
            if 1 <= a < n and 1 <= b < n:
                I_matrix[a-1, b-1] = I
                I_matrix[b-1, a-1] = I  # Symmetric
    
    # Create color matrix: -1=invalid/unknown, 0=light red, 1=white, 2=blue, 3=black
    color_matrix = np.full((n, n), -1, dtype=int)
    
    # Determine colors based on theorems and computation
    for a in range(1, n):
        for b in range(1, n):
            # Skip invalid generator indices (must be between 2 and n-1)
            if a < 2 or a > n-1 or b < 2 or b > n-1:
                continue
                
            I_val = I_matrix[a-1, b-1]
            if I_val == -1:  # No computation result
                continue
                
            result = proven_by_theorem(a, b, n)
            
            if result is not None:
                # Covered by theorems
                color_matrix[a-1, b-1] = 2 if result else 0
                color_matrix[b-1, a-1] = 2 if result else 0  # Symmetric
            else:
                # Not covered by theorems - use computation result
                color_matrix[a-1, b-1] = 3 if I_val == 1 else 1
                color_matrix[b-1, a-1] = 3 if I_val == 1 else 1  # Symmetric
    
    # Create masked array to hide invalid/unknown cells
    masked_color = np.ma.masked_equal(color_matrix, -1)
    
    # Plot
    plt.figure(figsize=(10, 8))
    plt.imshow(masked_color, cmap=cmap, norm=norm, aspect='equal', origin='lower')
    
    # Add grid lines for better readability on large n
    if n <= 20:
        plt.grid(color='gray', linestyle='-', linewidth=0.5)
    
    plt.xlabel('b', fontsize=12)
    plt.ylabel('a', fontsize=12)
    plt.title(f'Generating Triples (r_a, r_b, r_{n}) for n={n}', fontsize=14)
    
    # Set ticks to show generator indices (2 to n-1)
    tick_positions = np.arange(1, n-1)  # Skip 0 and n-1 (invalid indices)
    plt.xticks(tick_positions, tick_positions + 1)
    plt.yticks(tick_positions, tick_positions + 1)
    
    # Create custom legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='blue', label='Proven full group'),
        Patch(facecolor='black', label='Unproven full group'),
        Patch(facecolor='lightcoral', label='Proven subgroup'),
        Patch(facecolor='white', label='Unproven subgroup')
    ]
    plt.legend(handles=legend_elements, loc='upper right', bbox_to_anchor=(1.15, 1))
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f'n_{n}.png'), dpi=150)
    plt.close()

print(f"Generated {len(n_values)} colored grid plots in '{output_dir}' directory.")
