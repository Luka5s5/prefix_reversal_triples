# Pancake-graph

## Data Directory

The `data/` directory contains serialized SageMath objects (`.sobj`) and generated visualization PDFs from computational experiments.

### Files:

**Hamiltonian Cycle Search (n=7)**
- `all-3pancake-n7.sobj` - Collection of all 3-pancake graphs for n=7 with valid generator pairs
- `all-3pancake-n7-hamiltonian_cycle.sobj` - Results of Hamiltonian cycle search for all n=7 graphs

**Generator Pair Analysis**
- `Sn_DATA_70.sobj` - Count data for valid generator pairs $(a,b)$ where $\langle r_a, r_b, r_n \rangle = S_n$, for $6 \le n \le 70$
- `Sn_DATA_70.pdf` - Visualization showing growth of $|AB(n)|$ grouped by $n \bmod 4$, with fitted asymptotic curves

**Transitive and Primitive Groups**
- `transitive+primitive_DATA_100.sobj` - Generator pair data for groups that are both transitive and primitive, $n \le 100$
- `transitive+primitive_DATA_100.pdf` - Corresponding visualization with asymptotic fits

**Alternating Group Constraints**
- `transitive+primitive+geAn_DATA_100.sobj` - Data for groups satisfying: transitive, primitive, and $\langle r_a, r_b, r_n \rangle \supseteq A_n$, $n \le 100$
- `transitive+primitive+geAn_DATA_100.pdf` - Visualization showing growth patterns
- `transitive+primitive+leAn_DATA_70.sobj` - Data for groups satisfying: transitive, primitive, and $\langle r_a, r_b, r_n \rangle \subseteq A_n$, $n \le 70$
- `transitive+primitive+leAn_DATA_70.pdf` - Corresponding visualization

### Loading Data

To load serialized objects in SageMath:
```python
graphs = load("data/all-3pancake-n7.sobj")
data = load("data/Sn_DATA_70.sobj")
```

## Listing Directory

The `listing/` directory contains SageMath Python scripts for computational experiments on pancake graphs.

### Scripts:

**`all-3pancake-n7-hamiltonian_cycle_search.py`**

Searches for Hamiltonian cycles in 3-pancake graphs with n=7.

- **Input**: Predefined generator pairs `AB_PAIRS = [(2,4), (2,5), (2,6), (3,4), (3,6), (4,5), (4,6), (5,6)]` (each $(a,b)$ satisfies $2 \le a < b \le n-1$ for $n=7$)
- **Process**:
  - Constructs Cayley graphs on S_7 for each (a,b) pair using generators {r_a, r_b, r_n}
  - Computes graph properties: diameter, girth
  - Attempts to find Hamiltonian cycles using backtracking algorithm (up to 5000 attempts per graph)
- **Output**: 
  - `data/all-3pancake-n7.sobj` - All constructed graphs
  - `data/all-3pancake-n7-hamiltonian_cycle.sobj` - Graphs with found Hamiltonian cycles
  - `data/hamiltonian_cycles_n7.sobj` - Dictionary mapping $(a,b) \mapsto$ Hamiltonian cycle

**Usage**: `sage all-3pancake-n7-hamiltonian_cycle_search.py`

**Note**: Computationally expensive, may run for extended periods.

---

**`approx.py`**

Analyzes growth rates of valid generator pairs and fits asymptotic models.

- **Input**: Configurable parameters
  - `N_MAX` - maximum value of $n$ (default: $20$)
  - `M_CANDIDATES` - denominator candidates for rational model fitting (default: $5\text{--}200$)
  - `pred` - tests predicate (default: $G = S_n$ (full symmetric group))
- **Process**:
  - For each $n \in [4, N\_MAX]$, enumerates all pairs $(a,b)$ with $2 \le a < b \le n-1$
  - Counts valid pairs $|AB(n)|$ and groups by $n \bmod 4$
  - Fits rational model $\frac{x^2 + u x + v}{m}$ using least squares (minimizing RMSE)
- **Output**:
  - Interactive plot showing data points and fitted asymptotic curves
  - Console output with best-fit parameters $(m, u, v, \mathrm{RMSE})$ for each residue class
  - Color coding: black $(n \equiv 0)$, green $(n \equiv 1)$, blue $(n \equiv 2)$, red $(n \equiv 3)$ mod $4$

**Usage**: `sage approx.py`

**Mathematical Model**: Empirically $|AB(n)| \sim \dfrac{n^2}{m}$ where $m$ depends on $n \bmod 4$
