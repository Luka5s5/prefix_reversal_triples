from sage.all import *
from collections import deque
import itertools

def compute_diameter(S, G):
    identity = G.identity()
    visited = {identity: 0}
    queue = deque([identity])

    while queue:
        current = queue.popleft()
        current_dist = visited[current]
        for s in S:
            next_perm = current * s
            if next_perm not in visited:
                visited[next_perm] = current_dist + 1
                queue.append(next_perm)
    return max(visited.values())

def is_prefix_reversal(g, n):
    """Check if a permutation is a prefix reversal."""
    permuted = [g(i) for i in range(1, n+1)]
    for k in range(2, n+1):
        expected = list(range(k, 0, -1)) + list(range(k+1, n+1))
        if permuted == expected:
            return True
    return False

def canonical_form(triple, G):
    """Return the lexicographically minimal conjugated form of a triple."""
    min_rep = None
    triple_list = list(triple)

    for p in G:
        conj_triple = tuple(sorted([p * g * p.inverse() for g in triple_list], key=lambda x: str(x)))
        rep = tuple(str(g) for g in conj_triple)
        if (min_rep is None) or (rep < min_rep):
            min_rep = rep
    return min_rep

def main():
    n = int(input("Enter the value of n: "))
    G = SymmetricGroup(n)
    identity = G.identity()
    perms = list(G)

    # Filter out identity permutations
    non_id_perms = [g for g in perms if g != identity]

    # Set to store canonical forms of already processed triples
    seen_canonicals = set()

    for generators in itertools.combinations(non_id_perms, 3):
        S = set(generators)

        # Check if the set is closed under inversion
        inv_S = {g**(-1) for g in S}
        if S != inv_S:
            continue

        # Try to generate the subgroup
        try:
            H = G.subgroup(list(S))
        except:
            continue

        # Check if the subgroup is the full symmetric group
        if H != G:
            continue

        # Compute the canonical form
        cform = canonical_form(generators, G)

        # Skip if this conjugacy class was already processed
        if cform in seen_canonicals:
            continue
        seen_canonicals.add(cform)

        # Compute diameter
        diameter = compute_diameter(S, G)

        # Check if all permutations are prefix-reversals
        all_prefix = all(is_prefix_reversal(g, n) for g in generators)

        # Format output
        sorted_generators = sorted(generators, key=lambda x: str(x))
        suffix = " PREFIX!" if all_prefix else ""
        print(f"Triple: {tuple(sorted_generators)}, Diameter: {diameter}{suffix}")

if __name__ == "__main__":
    main()
