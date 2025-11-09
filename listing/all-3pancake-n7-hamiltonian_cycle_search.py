# -*- coding: utf-8 -*-
# ===============================================================
#  3-Pancake Graph Hamiltonian Cycle Search (n = 7)
#  File: all-3pancake-n7-hamiltonian_cycle_search.py
#
#  Description:
#    - Constructs all "3-pancake" graphs for given generator pairs (a,b).
#    - Each graph Γ is built on the vertices of S_n with edges
#      connecting permutations g,h if g * h^{-1} is one of the generators.
#    - Attempts to find Hamiltonian cycles in each Γ using backtracking.
#    - Saves all graphs and results.
# ===============================================================

from sageall import *

# --------------------------- Settings --------------------------

n = 7
Sn = Permutations(list(range(1, n + 1)))

# Pairs (a,b) defining the generator sets
AB_PAIRS = [(2, 4), (2, 5), (2, 6), (3, 4), (3, 6), (4, 5), (4, 6), (5, 6)]

# ---------------------- Helper functions -----------------------

def prefix_reversal(j, n):
    """Return prefix-reversal permutation r_j as a permutation group element."""
    if not (1 <= j <= n):
        raise ValueError(f"j must satisfy 1 ≤ j ≤ n, got j={j}, n={n}")
    perm = Permutation(list(range(j, 0, -1)) + list(range(j + 1, n + 1)))
    return perm.to_permutation_group_element()

# ---------------------- Graph Construction ---------------------

def build_pancake_graphs(n, ab_pairs):
    """Construct all graphs for given AB pairs and store them in a list."""
    graphs = []
    for (a, b) in ab_pairs:
        generators = [prefix_reversal(a, n), prefix_reversal(b, n), prefix_reversal(n, n)]
        Gamma = Graph()
        Gamma.add_vertices(Sn)
        for g in Gamma.vertices():
            for h in Gamma.vertices():
                if g * ~h in generators:
                    Gamma.add_edge((g, h))
        graphs.append(Gamma)
    return graphs

# ------------------ Hamiltonian Cycle Search -------------------

def backtrack_search(Gamma, tries):
    """Try to find a Hamiltonian cycle using backtracking algorithm."""
    for attempt in range(1, tries + 1):
        HC = Gamma.hamiltonian_cycle(algorithm='backtrack')
        if HC[0]:
            print(f"Hamiltonian cycle found on attempt {attempt}.")
            return HC[1]
    print("No Hamiltonian cycle found within given attempts.")
    return False

# ---------------------------- Main -----------------------------

def main():
    print("Building pancake graphs...")
    graphs = build_pancake_graphs(n, AB_PAIRS)
    save(graphs, "all-3pancake-n7")

    print("Starting Hamiltonian cycle search...")
    HC_DATA = {}

    for (i, (a, b)) in enumerate(AB_PAIRS):
        Gamma = graphs[i]
        print(f"\n===== Pair (a,b) = ({a},{b}) =====")
        print(f"Diameter: {Gamma.diameter()}")
        print(f"Girth: {Gamma.girth()}")
        print("Searching for Hamiltonian cycle...")
        HC = backtrack_search(Gamma, 5000)
        if HC:
            HC_DATA[(a, b)] = HC

    save(graphs, "all-3pancake-n7-hamiltonian_cycle")
    save(HC_DATA, "hamiltonian_cycles_n7")

    print("\nSearch complete.")
    if HC_DATA:
        print(f"Found Hamiltonian cycles for {len(HC_DATA)} pairs.")
    else:
        print("No Hamiltonian cycles found.")

if __name__ == "__main__":
    main()
