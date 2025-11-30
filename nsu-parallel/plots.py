import matplotlib.pyplot as plt
import numpy as np
import re

def parse_benchmark_results(filename):
    """Parse benchmark results from the text file."""
    with open(filename, 'r') as file:
        content = file.read()
    
    # Split the content into individual benchmark sections
    benchmarks = re.split(r'❯ hyperfine', content)[1:]
    
    results = {
        'one_deep_search': {'parallel': 0.0, 'regular': 0.0},
        'multiple_shallow_searches': {'parallel': 0.0, 'regular': 0.0}
    }
    
    for benchmark in benchmarks:
        # Extract command and time
        cmd_match = re.search(r"'\./(parallel|regular)_benchmark\s+(.*)'", benchmark)
        time_match = re.search(r"Time \(mean ± σ\):\s+([\d.]+)\s+s", benchmark)
        
        if cmd_match and time_match:
            impl_type = cmd_match.group(1)  # 'parallel' or 'regular'
            args = cmd_match.group(2).strip()
            time_val = float(time_match.group(1))
            
            # Categorize based on arguments
            if args == "1 -2 5 10 11 2":
                results['one_deep_search'][impl_type] = time_val
            elif args == "0 -3 11 13 2500 6":
                results['multiple_shallow_searches'][impl_type] = time_val
    
    return results

# Parse the benchmark results from file
results = parse_benchmark_results('benchresults.txt')

# Extract the values for plotting
one_deep_parallel = results['one_deep_search']['parallel']
one_deep_regular = results['one_deep_search']['regular']
multi_shallow_parallel = results['multiple_shallow_searches']['parallel']
multi_shallow_regular = results['multiple_shallow_searches']['regular']

# Data preparation
labels = ['One deep search', 'Multiple shallow searches']
parallel_times = [one_deep_parallel, multi_shallow_parallel]
regular_times = [one_deep_regular, multi_shallow_regular]

x = np.arange(len(labels))
width = 0.35  # Width of the bars

# Create the figure and axis
fig, ax = plt.subplots(figsize=(10, 6))

# Create bars
bars1 = ax.bar(x - width/2, parallel_times, width, label='Parallel Implementation', color='skyblue')
bars2 = ax.bar(x + width/2, regular_times, width, label='Regular Implementation', color='salmon')

# Add labels, title and legend
ax.set_ylabel('Execution Time (seconds)', fontsize=12)
ax.set_title('Performance Comparison: Parallel vs Regular BFS Implementation', fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.legend()

# Add value labels on top of bars
def add_labels(bars):
    for bar in bars:
        height = bar.get_height()
        ax.annotate(f'{height:.2f}s',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')

add_labels(bars1)
add_labels(bars2)

# Calculate and display speedup
for i, (parallel, regular) in enumerate(zip(parallel_times, regular_times)):
    if parallel > 0:  # Avoid division by zero
        speedup = regular / parallel
        ax.text(i, max(parallel, regular) * 0.95, 
                f'Speedup: {speedup:.2f}x', 
                ha='center', fontsize=10, fontweight='bold',
                bbox=dict(facecolor='white', alpha=0.8, edgecolor='gray'))

# Add grid for better readability
ax.grid(axis='y', linestyle='--', alpha=0.7)

# Adjust layout and show plot
plt.tight_layout()

# Save the figure
plt.savefig('bfs_performance_comparison.png', dpi=300, bbox_inches='tight')

# Show the plot
plt.show()

print("Chart generated successfully and saved as 'bfs_performance_comparison.png'")
