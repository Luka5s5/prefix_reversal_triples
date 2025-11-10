import ast
import os
from collections import defaultdict
from math import log

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

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
                if a <= b and n >= 2:
                    data.append((a, b, n, I))
                    data.append((b, a, n, I))
        except Exception as e:
            print(f"Skipping line due to error: {line} | Error: {e}")


# Precompute generating pairs per n (I=1)
generating_pairs = defaultdict(list)
for (a, b, n, I) in data:
    generating_pairs[n].append((a, b, I))

# Task 1: Proportion of proven cases for each n
minn, maxn = 2, 100
n_values = list(range(2, 101))
total_generating = [0] * 101  # Index 0 unused, 1..100
proven_generating = [0] * 101

cmap = mpl.colormaps['viridis']

for n in n_values:
    pairs = generating_pairs.get(n, [])
    total_generating[n] = len(pairs)
    for (a, b, I) in pairs:
        if b == a + 1 or b == n - 1 or b == n - 2:
            proven_generating[n] += 1

proportions = []
for n in n_values:
    total = total_generating[n]
    proven = proven_generating[n]
    proportions.append(proven / total if total > 0 else 0)
'''
# Plot proportion bar chart
plt.figure(figsize=(14, 7))
plt.bar(n_values, proportions, color='skyblue', edgecolor='black')
plt.xlabel('n', fontsize=12)
plt.ylabel('Proportion', fontsize=12)
plt.title('Proportion of Generating Triples Covered by Proven Cases', fontsize=14)
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.xticks(np.arange(2, 101, step=5), rotation=45)
plt.tight_layout()
plt.savefig('proven_proportion.png', dpi=300)
plt.show()

# Task 2: Closeness histogram
closeness_list = []
for n in n_values:
    pairs = generating_pairs.get(n, [])
    for (a, b) in pairs:
        diff1 = (b - a) / n
        diff2 = (n - b) / n
        closeness = min(diff1, diff2)
        closeness_list.append(closeness)

# Plot histogram
plt.figure(figsize=(10, 6))
plt.hist(closeness_list, bins=50, color='teal', alpha=0.7, edgecolor='black')
plt.xlabel('Closeness Number', fontsize=12)
plt.ylabel('Frequency', fontsize=12)
plt.title('Distribution of Closeness in Generating Triples', fontsize=14)
plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.tight_layout()
plt.savefig('closeness_histogram.png', dpi=300)
plt.show()
'''
# Task 3: Grid plots for each n
output_dir = 'grid_plots_bw'
os.makedirs(output_dir, exist_ok=True)

def choose_color(x):
    if x == 1:
        return 0.0
    if x == 2:
        return -0.5
    else:
        return -log(x)

def matrix_to_rgb(matrix):
    """Convert matrix to RGB image with:
    - 0.0 → blue
    - -0.5 → green
    - Other values → grayscale (black at min value, white at 0.0)
    """
    # Handle empty matrices immediately
    if matrix.size == 0:
        return np.zeros((0, 0, 3))
    
    tol = 1e-5
    rgb = np.zeros(matrix.shape + (3,))
    
    mask_zero = np.isclose(matrix, 0.0, atol=tol)
    mask_half = np.isclose(matrix, -0.5, atol=tol)
    mask_other = ~(mask_zero | mask_half)
    
    # Apply special colors
    rgb[mask_zero] = [0, 0, 0]    # Blue for 0.0
    rgb[mask_half] = [0, 0.2, 0]    # Green for -0.5
    
    # Handle other values with grayscale mapping
    if np.any(mask_other):
        other_vals = matrix[mask_other]
        
        # Skip if no valid values (shouldn't happen due to mask check, but safe)
        if other_vals.size == 0:
            return rgb
            
        min_val = other_vals.min()
        
        # Handle case where all values are zero or positive
        if min_val >= 0:
            normalized = np.ones_like(other_vals)  # All white
        else:
            # Normalize: min_val → 0 (black), 0.0 → 1 (white)
            normalized = (other_vals - min_val) / (-min_val)
            normalized = np.clip(normalized, 0, 1)
        
        # Apply grayscale
        gray = np.stack([1-normalized, 1-normalized, 1-normalized], axis=-1)
        rgb[mask_other] = gray
    
    return rgb

# MAIN LOOP
for n in n_values:
    # Skip invalid matrix sizes
    if n <= 2:
        print(f"Skipping n={n} (matrix would be empty)")
        continue
        
    matrix = np.full((n-2, n-2), 0.0, dtype=float)
    for (a, b, I) in generating_pairs.get(n, []):
        matrix[a-2, b-2] = 1 if I==1 else 0#-log(I)
    
    if n == 10:
        print("Matrix for n=10:")
        print(matrix)

    # Convert to RGB image
    rgb_image = matrix_to_rgb(matrix)
    
    plt.figure(figsize=(10, 8))
    plt.imshow(matrix, cmap='binary', aspect='equal', origin='lower')

    # # Only annotate small matrices to avoid clutter/crashes
    # if n <= 25:  # Adjust threshold as needed
    #     for i in range(matrix.shape[0]):
    #         for j in range(matrix.shape[1]):
    #             val = matrix[i, j]
    #             label = "-0.5" if np.isclose(val, -0.5) else f"{val:.2f}"
    #             plt.text(j, i, label,
    #                      ha='center', va='center',
    #                      color='red',
    #                      fontsize=8,
    #                      fontweight='bold',
    #                      bbox=dict(facecolor='white', alpha=0.5, edgecolor='none', pad=0.1))

    plt.xlabel('b', fontsize=12)
    plt.ylabel('a', fontsize=12)
    plt.title(f'Generating Pairs (a, b) for n={n}', fontsize=14)
    
    # Calculate tick positions safely
    tick_step = max(1, (n-2)//10)
    xticks = np.arange(0, n-2, tick_step)
    yticks = np.arange(0, n-2, tick_step)
    
    if len(xticks) > 0 and len(yticks) > 0:
        plt.xticks(xticks, np.arange(2, n, tick_step))
        plt.yticks(yticks, np.arange(2, n, tick_step))
    else:
        plt.xticks([])
        plt.yticks([])

    # REMOVE COLORBAR - not compatible with RGB images
    # plt.colorbar(...)  <-- This line caused crashes
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f'n_{n:03d}.png'), dpi=150, bbox_inches='tight')
    plt.close()

print(f"Generated plots for {len([n for n in n_values if n > 2])} values of n in '{output_dir}' directory.")
