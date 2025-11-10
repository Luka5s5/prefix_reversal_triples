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

def main():
    n = int(input("Enter the value of n: "))
    G = SymmetricGroup(n)
    identity = G.identity()
    perms = list(G)

    # Filter out identity permutations
    non_id_perms = [g for g in perms if g != identity]

    # Iterate through all 3-element combinations of non-identity permutations
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

        # Compute the diameter of the Cayley graph
        diameter = compute_diameter(S, G)

        # Print the result in a consistent format
        sorted_generators = sorted(generators, key=lambda x: str(x))
        print(f"Triple: {tuple(sorted_generators)}, Diameter: {diameter}")

if __name__ == "__main__":
    main()
