from sage.all import *
from collections import defaultdict

maxn = 51

def Prefix(n, k):
    l = [i + 1 for i in range(n)]
    l = l[:k][::-1] + l[k:]
    return Permutation(list(l))

def analyze_periodic_structure():
    """
    Analyze the 4-periodic structure of generating triples {r_a, r_b, r_n}
    """
    # Store successful generating triples by n mod 4
    generating_by_mod = {i: [] for i in range(4)}
    
    results = {}
    
    print("Computing generating triples for n = 4 to 100...")
    
    for n in range(4, maxn):
        print(f"Processing n = {n} ({n*100//maxn:.1f}%)")
        
        sn_size = SymmetricGroup(n).cardinality()
        successful_pairs = []
        
        # Check all pairs (a, b) with 2 <= a < b < n
        for a in range(2, n):
            for b in range(a + 1, n):
                try:
                    r_a = Prefix(n, a)
                    r_b = Prefix(n, b)
                    r_n = Prefix(n, n)
                    
                    G = PermutationGroup([r_a, r_b, r_n])
                    if G.cardinality() == sn_size:
                        successful_pairs.append((a, b))
                except:
                    continue  # Skip if group construction fails
        
        results[n] = successful_pairs
        
        # Group by n mod 4
        mod_class = n % 4
        for pair in successful_pairs:
            generating_by_mod[mod_class].append((pair[0], pair[1], n))
    
    # Analyze the patterns
    print("\n=== ANALYSIS OF 4-PERIODIC STRUCTURE ===")
    
    for mod_val in range(4):
        print(f"\nn ≡ {mod_val} (mod 4):")
        mod_data = [(a, b, n) for a, b, n in generating_by_mod[mod_val]]
        print(f"  Total successful triples with n ≡ {mod_val} (mod 4): {len(mod_data)}")
        
        if len(mod_data) > 0:
            # Group by (a,b) pattern
            ab_patterns = {}
            for a, b, n in mod_data:
                if (a, b) not in ab_patterns:
                    ab_patterns[(a, b)] = []
                ab_patterns[(a, b)].append(n)
            
            # Show patterns
            print(f"  Unique (a,b) pairs that work for n ≡ {mod_val} (mod 4): {len(ab_patterns)}")
            
            # Print some examples
            example_count = 0
            for (a, b), n_list in ab_patterns.items():
                if example_count < 10:  # Show first 10 examples
                    print(f"    r_{a}, r_{b}: works for n = {n_list}")
                    example_count += 1
    
    # Check the periodic structure more carefully
    print(f"\n=== CHECKING PERIODIC STRUCTURE ===")
    
    # Compare n and n+4 for each class
    for start_mod in range(4):
        print(f"\nFor n ≡ {start_mod} (mod 4), comparing n values:")
        n_vals = [n for n in range(4, maxn) if n % 4 == start_mod]
        
        for i in range(len(n_vals) - 1):
            n1 = n_vals[i]
            n2 = n_vals[i + 1]  # This is typically n1+4, but could be n1+8, etc.
            
            pairs_n1 = set(results.get(n1, []))
            pairs_n2 = set(results.get(n2, []))
            
            # Convert pairs_n2 to be comparable to pairs_n1
            # For now, let's just check overlap of small (a,b) values
            common_pairs = pairs_n1.intersection(pairs_n2)
            n1_only = pairs_n1.difference(pairs_n2)
            n2_only = pairs_n2.difference(pairs_n1)
            
            print(f"  n={n1}, n'={n2}: |common|={len(common_pairs)}, |{n1} only|={len(n1_only)}, |{n2} only|={len(n2_only)}")
            
            # Show some common pairs if they exist
            if len(common_pairs) > 0:
                sample_common = list(common_pairs)[:3]  # Show first 3
                print(f"    Sample common pairs: {sample_common}")
    
    # Statistical analysis: measure similarity between n's in the same class
    print(f"\n=== STATISTICAL ANALYSIS OF PERIODICITY ===")
    
    for mod_val in range(4):
        n_vals = [n for n in range(4, maxn) if n % 4 == mod_val]
        n_pairs = []
        
        # Compare consecutive pairs
        for i in range(len(n_vals) - 1):
            n1, n2 = n_vals[i], n_vals[i+1]
            pairs1, pairs2 = set(results.get(n1, [])), set(results.get(n2, []))
            
            if len(pairs1) > 0 or len(pairs2) > 0:
                intersection = len(pairs1.intersection(pairs2))
                union_size = len(pairs1.union(pairs2))
                jaccard = intersection / union_size if union_size > 0 else 0
                n_pairs.append((n1, n2, jaccard))
        
        if n_pairs:
            avg_similarity = sum(pair[2] for pair in n_pairs) / len(n_pairs)
            print(f"  n ≡ {mod_val} (mod 4): Average Jaccard similarity between consecutive n's = {avg_similarity:.3f}")
    
    return results, generating_by_mod

def verify_specific_patterns():
    """
    Verify specific patterns mentioned in the conjecture
    """
    print("\n=== VERIFYING SPECIFIC PATTERNS ===")
    
    # Check if certain (a, b) pairs follow predictable patterns based on n mod 4
    pattern_data = defaultdict(list)
    
    for n in range(4, maxn):
        sn_size = SymmetricGroup(n).cardinality()
        
        for a in range(2, min(10, n)):  # Check smaller values of a
            for b in range(a + 1, min(15, n)):  # Check smaller values of b
                try:
                    r_a = Prefix(n, a)
                    r_b = Prefix(n, b)
                    r_n = Prefix(n, n)
                    
                    G = PermutationGroup([r_a, r_b, r_n])
                    if G.cardinality() == sn_size:
                        pattern_data[(a, b)].append(n)
                except:
                    continue
    
    # Analyze patterns for specific (a, b) pairs
    print("Patterns for specific (a,b) pairs:")
    for (a, b), n_list in sorted(pattern_data.items()):
        if len(n_list) >= 5:  # Only show if it works for 5+ values
            mods = [n % 4 for n in n_list]
            mod_counts = {i: mods.count(i) for i in range(4)}
            print(f"  r_{a}, r_{b}: works for n = {n_list[:10]}{'...' if len(n_list) > 10 else ''}")
            print(f"    n mod 4 distribution: {mod_counts}")

def main():
    print("Verifying 4-periodic structure conjecture for prefix-reversal triples...")
    print("This will check if {r_a, r_b, r_n} exhibits 4-periodic behavior in generation of S_n")
    
    results, generating_by_mod = analyze_periodic_structure()
    verify_specific_patterns()
    
    print(f"\n=== SUMMARY ===")
    print("The analysis shows the 4-periodic structure by:")
    print("1. Grouping successful generating triples by n mod 4")
    print("2. Computing similarity measures between n values with same mod 4")
    print("3. Identifying patterns in (a,b) pairs across n values")
    
    return results

if __name__ == "__main__":
    main()
