from sage.all import *
from collections import deque, defaultdict
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

    # Dictionary to map canonical forms to whether any of their triples are prefix-reversals
    canonical_classes = defaultdict(bool)

    # List to store all valid results for final output
    results = []
    combos = itertools.combinations(non_id_perms, 3)

    tot_perms = len(non_id_perms)
    lencombos = int(tot_perms*(tot_perms-1)*(tot_perms-2)//6)
    update_interval = max(1, lencombos // 10)

    for idx,generators in enumerate(combos):
        S = set(generators)
        if idx % update_interval == 0:
            percent = (idx / lencombos) * 100
            print(f"Progress: {percent:.0f}%", flush=True)
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

        # Check if this triple is composed of prefix-reversals
        is_prefix = all(is_prefix_reversal(g, n) for g in generators)

        # Compute the canonical form
        cform = canonical_form(generators, G)

        # Update the conjugacy class with prefix info
        if is_prefix:
            canonical_classes[cform] = True
        elif cform not in canonical_classes:
            canonical_classes[cform] = False

        # Compute diameter
        diameter = compute_diameter(S, G)

        # Store the result for final output
        sorted_generators = sorted(generators, key=lambda x: str(x))
        results.append((cform, tuple(sorted_generators), diameter, is_prefix))

    # Now, collect final unique conjugacy classes with correct prefix marking
    final_output = {}

    for cform, generators, diameter, _ in results:
        if cform in final_output:
            # Keep the one with the smallest diameter, or any other logic
            if diameter < final_output[cform][1]:
                final_output[cform] = (generators, diameter, canonical_classes[cform])
        else:
            final_output[cform] = (generators, diameter, canonical_classes[cform])

    # Print all final results
    for cform, (generators, diameter, is_prefix) in final_output.items():
        suffix = " PREFIX!" if is_prefix else ""
        print(f"Triple: {generators}, Diameter: {diameter}{suffix}")

if __name__ == "__main__":
    main()
