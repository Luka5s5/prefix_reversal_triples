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

def find_shortest_nontrivial_cycle(generators, max_search_depth=20):
    """
    Find the shortest non-trivial cycle in a Cayley graph and return both the length and the cycle sequence.
    
    Parameters:
    - generators: list of generator permutations
    - max_search_depth: maximum depth to search for cycles
    
    Returns:
    - cycle_length: length of the shortest non-trivial cycle
    - cycle_sequence: list of generator indices forming the cycle
    """
    G = PermutationGroup(generators)
    group_gens = [G(gen) for gen in generators]
    num_gens = len(group_gens)
    identity = G.identity()
    
    # BFS queue: (current_element, path_from_identity, last_generator_used)
    # path_from_identity is a list of generator indices used to reach this element
    queue = deque()
    queue.append((identity, [], None))  # Start with identity, empty path, no last generator
    
    # visited[vertex] = (path_length, last_generator_used) to avoid revisiting with worse paths
    visited = {identity: (0, None)}
    
    while queue:
        current, path, last_gen = queue.popleft()
        current_depth = len(path)
        
        if current_depth >= max_search_depth:
            continue
            
        for gen_idx, gen in enumerate(group_gens):
            # Skip immediate backtracking: don't use the same generator twice in a row
            if last_gen == gen_idx:
                continue
                
            neighbor = current * gen
            
            # Case 1: Found a cycle back to identity with non-trivial path
            if neighbor == identity and current_depth >= 1:
                # This is a valid cycle: path + [gen_idx] brings us back to identity
                cycle_sequence = path + [gen_idx]
                cycle_length = len(cycle_sequence)
                
                # Filter out trivial 2-cycles (which are just g*g = identity)
                if cycle_length >= 3:
                    return cycle_length, cycle_sequence
            
            # Case 2: Found a cycle through a previously visited vertex
            if neighbor in visited:
                prev_depth, prev_last_gen = visited[neighbor]
                
                # Skip if this is just the reverse path (trivial cycle)
                if current_depth == prev_depth and path[:-1] == [] and last_gen == gen_idx:
                    continue
                
                # Check if this forms a non-trivial cycle
                if current_depth + 1 > prev_depth:
                    # This path is longer, but we found a cycle
                    cycle_length = current_depth + 1 + prev_depth
                    
                    # Only consider non-trivial cycles (length >= 3)
                    if cycle_length >= 3:
                        # Construct the cycle sequence
                        # Path from identity to current: path + [gen_idx]
                        # Path from identity to neighbor: the stored path (we don't store full paths in visited for memory)
                        # Instead, we return the cycle length and can reconstruct later if needed
                        return cycle_length, None  # We can't easily reconstruct the full sequence here
            
            # If not visited or found a shorter path to this vertex, add to queue
            if neighbor not in visited or current_depth + 1 < visited[neighbor][0]:
                visited[neighbor] = (current_depth + 1, gen_idx)
                queue.append((neighbor, path + [gen_idx], gen_idx))
    
    return None, None  # No non-trivial cycle found within search depth

def compute_girth_with_cycle(gens, max_search_depth=20):
    """
    Compute girth and return the actual cycle sequence for non-trivial cycles.
    """
    # First try to find the girth length using a more efficient method
    girth_length = compute_girth_simple(gens, max_search_depth)
    if girth_length is None:
        return None, None
    
    # Now find the actual cycle sequence with that length
    cycle_seq = find_cycle_of_length(gens, girth_length)
    return girth_length, cycle_seq

def compute_girth_simple(gens, max_search_depth=20):
    """
    Efficiently compute just the girth length (ignoring trivial 2-cycles).
    """
    G = PermutationGroup(gens)
    group_gens = [G(g) for g in gens]
    identity = G.identity()
    
    # BFS with state: (current_element, distance_from_identity, last_generator_used)
    queue = deque()
    queue.append((identity, 0, None))
    visited = {identity: (0, None)}
    
    while queue:
        current, dist, last_gen = queue.popleft()
        
        if dist >= max_search_depth:
            continue
            
        for gen_idx, gen in enumerate(group_gens):
            # Skip immediate backtracking
            if last_gen == gen_idx:
                continue
                
            neighbor = current * gen
            
            # Check for cycle back to identity (non-trivial)
            if neighbor == identity and dist > 0:
                cycle_length = dist + 1
                if cycle_length >= 3:  # Skip trivial 2-cycles
                    return cycle_length
            
            # Check for cycle through visited vertex
            if neighbor in visited:
                prev_dist, _ = visited[neighbor]
                cycle_length = dist + 1 + prev_dist
                if cycle_length >= 3:  # Skip trivial cycles
                    return cycle_length
            
            # Add to queue if not visited or found shorter path
            if neighbor not in visited or dist + 1 < visited[neighbor][0]:
                visited[neighbor] = (dist + 1, gen_idx)
                queue.append((neighbor, dist + 1, gen_idx))
    
    return None

def find_cycle_of_length(gens, target_length):
    """
    Find an actual cycle sequence of the given length.
    This is a brute-force approach but works for small girth values.
    """
    G = PermutationGroup(gens)
    group_gens = [G(g) for g in gens]
    identity = G.identity()
    num_gens = len(group_gens)
    
    # Use DFS to find a cycle of exactly target_length
    def dfs(current, path, last_gen):
        if len(path) == target_length:
            if current == identity and len(set(path)) > 1:  # Non-trivial cycle
                return path
            return None
        
        if len(path) > target_length:
            return None
        
        for gen_idx, gen in enumerate(group_gens):
            # Skip immediate backtracking
            if last_gen == gen_idx:
                continue
            
            # For efficiency, prune if we can't reach target_length
            remaining = target_length - len(path)
            if remaining == 1 and current * gen != identity:
                continue
            
            next_vertex = current * gen
            result = dfs(next_vertex, path + [gen_idx], gen_idx)
            if result is not None:
                return result
        
        return None
    
    return dfs(identity, [], None)

# Example usage for small n (n=4,5,6)
if __name__ == "__main__":
    for n in range(4, 8):  # Limit to smaller n for demonstration
        print(f"\n=== Computing for n={n} ===")
        results = compute_triples_diameters(n)
        print(f"\nResults for n={n}:")
        for b1, b2, n_val, diam in results:
            gens = [Prefix(n_val, b1), Prefix(n_val, b2), Prefix(n_val, n_val)]
            girth = compute_girth_simple(gens, max_search_depth=15)
            
            cycle_seq = None
            if girth is not None:
                cycle_seq = find_cycle_of_length(gens, girth)
            
            # Format cycle sequence nicely
            cycle_str = "not found"
            if cycle_seq is not None:
                # Map generator indices to meaningful names
                gen_names = [f"r{b1}", f"r{b2}", f"r{n_val}"]
                cycle_str = " -> ".join(gen_names[idx] for idx in cycle_seq)
            
            print(f"Triple ({b1}, {b2}, {n_val}) has diameter {diam}, girth {girth}, cycle: {cycle_str}")
            
            # Optional verification
            if cycle_seq is not None:
                G = PermutationGroup(gens)
                current = G.identity()
                for idx in cycle_seq:
                    current = current * G(gens[idx])
                print(f"  Verification: {'SUCCESS' if current == G.identity() else 'FAILED'}")
