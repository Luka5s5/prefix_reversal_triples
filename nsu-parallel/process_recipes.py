#!/usr/bin/env python3

import sys


def solve() -> None:
    data = sys.stdin.read().splitlines()
    if not data:
        return
    n = int(data[0].strip())
    strings = [line.strip() for line in data[1:1+n] if line.strip() != '']

    if not strings:
        print("")
        return

    # Precompute max length
    max_len = max(len(s) for s in strings)

    # Base and moduli for rolling hash
    base = 3
    mod1 = 10**9 + 7
    mod2 = 10**9 + 9

    # Precompute powers
    pow1 = [1] * (max_len + 1)
    pow2 = [1] * (max_len + 1)
    for i in range(1, max_len + 1):
        pow1[i] = (pow1[i-1] * base) % mod1
        pow2[i] = (pow2[i-1] * base) % mod2

    # Precompute prefix hashes for each string
    prefixes = []  # list of (pref1, pref2) for each string
    for s in strings:
        pref1 = [0] * (len(s) + 1)
        pref2 = [0] * (len(s) + 1)
        for j, ch in enumerate(s):
            val = ord(ch) - ord('0')
            pref1[j+1] = (pref1[j] * base + val) % mod1
            pref2[j+1] = (pref2[j] * base + val) % mod2
        prefixes.append((pref1, pref2))

    best_reduction = 0
    best_pattern = ""

    # Try all possible pattern lengths
    for L in range(2, max_len + 1):
        # Upper bound: if even the theoretical maximum reduction for this L
        # cannot beat the current best, skip this L.
        max_possible = sum((len(s) // L) for s in strings) * (L - 1)
        if max_possible <= best_reduction:
            continue

        # global_count[key] = [total_non_overlap_count, example_substring]
        global_count = {}

        for idx, s in enumerate(strings):
            pref1, pref2 = prefixes[idx]
            slen = len(s)
            if slen < L:
                continue

            # local map from hash to list of start positions
            local = {}
            for i in range(slen - L + 1):
                h1 = (pref1[i+L] - pref1[i] * pow1[L]) % mod1
                h2 = (pref2[i+L] - pref2[i] * pow2[L]) % mod2
                key = (h1, h2)
                local.setdefault(key, []).append(i)

            # For each distinct substring in this string,
            # compute non‑overlapping occurrences greedily
            for key, positions in local.items():
                # positions are already in increasing order
                cnt = 0
                last_end = -L  # last end position, start far left
                for p in positions:
                    if p >= last_end:
                        cnt += 1
                        last_end = p + L
                # Update global counts
                if key not in global_count:
                    # store the actual substring from the first occurrence
                    example = s[positions[0]:positions[0]+L]
                    global_count[key] = [0, example]
                global_count[key][0] += cnt

        # Evaluate all patterns of length L
        for total_cnt, example in global_count.values():
            reduction = (L - 1) * total_cnt
            if reduction > best_reduction:
                best_reduction = reduction
                best_pattern = example

    # Output the best pattern (empty string if no reduction possible)
    print(best_pattern)

if __name__ == "__main__":
    solve()
