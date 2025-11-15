from sage.groups.perm_gps.permgroup import PermutationGroup
from collections import deque

def Prefix(n,k):
    """Create a prefix reversal permutation on n elements, reversing first k elements."""
    l = [i+1 for i in range(n)]
    l = l[:k][::-1] + l[k:]
    return Permutation(list(tuple(l)))

def cayley_graph_diameter_bfs(generators):
    """
    Compute diameter using BFS from identity element.
    All generators must be Permutation objects.
    """
    # Create the permutation group
    G = PermutationGroup(generators)
    
    # Get the generators as elements of the group G
    group_gens = [G(gen) for gen in generators]
    
    identity = G.identity()
    
    # BFS from identity
    visited = {identity: 0}
    queue = deque([identity])
    max_distance = 0
    
    while queue:
        current = queue.popleft()
        current_dist = visited[current]
        
        for gen in group_gens:
            # Multiply on the right (standard for Cayley graphs)
            neighbor = current * gen
            if neighbor not in visited:
                visited[neighbor] = current_dist + 1
                queue.append(neighbor)
                if current_dist + 1 > max_distance:
                    max_distance = current_dist + 1
    
    return max_distance

def compute_triples_diameters(n):
    """
    Find all generating triples of prefix reversals for S_n and compute their diameters.
    A triple consists of: Prefix(n,b1), Prefix(n,b2), Prefix(n,n) where 2 ≤ b1 < b2 < n
    """
    results = []
    Sn = SymmetricGroup(n)
    Sn_card = Sn.cardinality()
    
    for b1 in range(2, n-1):
        for b2 in range(b1+1, n):
            gens = [Prefix(n, b1), Prefix(n, b2), Prefix(n, n)]
            G = PermutationGroup(gens)
            if G.cardinality() == Sn_card:  # This triple generates the whole group
                print(f"Found generating triple: ({b1}, {b2}, {n})")
                
                diam = cayley_graph_diameter_bfs(gens)
                results.append((b1, b2, n, diam))
                print(f"  Diameter: {diam}")
    
    return results

def compute_girth_bruteforce(gens, max_length=18):
    G = PermutationGroup(gens)
    identity = G.identity()
    generators = [G(gen) for gen in gens]
    # Since generators are involutions, we only need to consider even lengths
    # and avoid consecutive identical generators
    
    # Start with length 2
    for length in range(2, max_length + 1, 2):  # even lengths only
        # Generate all words of this length without consecutive identical generators
        # and without immediate backtracking (but since involutions, backtracking is same as repeating)
        
        # We'll use recursion or iterative generation
        words = [[]]
        for _ in range(length):
            new_words = []
            for word in words:
                for i, gen in enumerate(generators):
                    # Skip if this would create consecutive identical generators
                    if word and word[-1] == i:
                        continue
                    new_words.append(word + [i])
            words = new_words
        
        # Check each word
        for word in words:
            # Evaluate the word
            current = identity
            for gen_idx in word:
                current = current * generators[gen_idx]
            
            if current == identity:
                # Found a relation
                return length
    
    return None  # not found within max_length

# Example usage for small n (n=4,5,6)
if __name__ == "__main__":
    for n in range(4, 11):
        print(f"\n=== Computing for n={n} ===")
        results = compute_triples_diameters(n)
        print(f"\nResults for n={n}:")
        for b1, b2, n, diam in results:
            girth = compute_girth_bruteforce([Prefix(n,b1),Prefix(n,b2),Prefix(n,n)])
            print(f"Triple ({b1}, {b2}, {n}) has diameter {diam}, girth {girth}")
