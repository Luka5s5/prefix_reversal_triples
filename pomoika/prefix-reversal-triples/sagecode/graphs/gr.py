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
                if a < b and n >= 2:
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

for n in n_values:
    matrix = np.zeros((n, n), dtype=int)
    for (a, b, I) in generating_pairs.get(n, []):
        matrix[a-1, b-1] = 1 if I==1 else 0
        print(log(1/I),I)
    
    plt.figure(figsize=(10, 8))
    plt.imshow(matrix, cmap='binary', aspect='equal', origin='lower')
    plt.xlabel('b', fontsize=12)
    plt.ylabel('a', fontsize=12)
    plt.title(f'Generating Pairs (a, b) for n={n}', fontsize=14)
    plt.xticks(np.arange(0, n, max(1, n//10)), np.arange(1, n+1, max(1, n//10)))
    plt.yticks(np.arange(0, n, max(1, n//10)), np.arange(1, n+1, max(1, n//10)))
    plt.colorbar(label='Generates S_n' if n <= 20 else '', ticks=[0, 1])
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, f'n_{n:03d}.png'), dpi=150)
    plt.close()

print(f"Generated {len(n_values)} grid plots in '{output_dir}' directory.")
