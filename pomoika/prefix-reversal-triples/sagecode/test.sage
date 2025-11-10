from sage.all import *
from collections import deque

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
    perms = list(G)

    for a in perms:
        for b in perms:
            for c in perms:
                S = {a, b, c}
                inv_S = {g**(-1) for g in S}
                if S == inv_S:
                    # Generate subgroup from the set S
                    try:
                        H = G.subgroup(list(S))
                    except:
                        continue  # Skip invalid subgroup (e.g., empty set)
                    if H == G:
                        diameter = compute_diameter(S, G)
                        print(f"Triple: ({a}, {b}, {c}), Diameter: {diameter}")

if __name__ == "__main__":
    main()
