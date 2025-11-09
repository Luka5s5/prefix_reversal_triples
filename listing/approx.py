# -*- coding: utf-8 -*-
# ===============================================================
#  AB-pairs and their growth approximation using SageMath
#  File: approx.py
#
#  Description:
#    1) For each n ∈ [4..N_MAX], iterate over pairs (a,b) with 2 ≤ a < b ≤ n-1.
#    2) Construct the group G = < r_a, r_b, r_n > where r_j is the prefix-reversal permutation.
#    3) Keep pairs (a,b) satisfying pred(G, n).
#    4) Compute |AB(n)| for each n and group results by n mod 4.
#    5) Fit the model (x^2 + u x + v)/m minimizing RMSE over m candidates.
#    6) Plot points and asymptotic curves.
# ===============================================================

from sageall import *

# -------------------------- Settings --------------------------

N_MAX = 20                      # upper bound for n (inclusive)
M_CANDIDATES = range(5, 200)    # candidates for denominator m in model
REAL_PREC = 96                  # precision for RealField

# Colors for each residue mod 4
COLORS = {0: 'black', 1: 'green', 2: 'blue', 3: 'red'}

# Predicate: True if G is the full symmetric group S_n
pred = lambda G, n: G.order() == factorial(n)

# ---------------------- Helper functions ----------------------

def prefix_reversal(j, n):
    """Return prefix reversal r_j as a permutation group element."""
    if not (1 <= j <= n):
        raise ValueError(f"j must satisfy 1 ≤ j ≤ n, got j={j}, n={n}")
    perm = Permutation(list(range(j, 0, -1)) + list(range(j+1, n+1)))
    return perm.to_permutation_group_element()

def collect_ab_pairs(n_min=4, n_max=N_MAX):
    """Build dictionary AB_by_n: for each n, list of valid (a,b) pairs."""
    AB_by_n = {}
    for n in range(n_min, n_max + 1):
        AB_by_n[n] = []
        for a in range(2, n-1):
            for b in range(a+1, n):
                r_a = prefix_reversal(a, n)
                r_b = prefix_reversal(b, n)
                r_n = prefix_reversal(n, n)
                G = PermutationGroup([r_a, r_b, r_n])
                if pred(G, n):
                    AB_by_n[n].append((a, b))
    return AB_by_n

# -------------------------- Fitting ---------------------------

def fit_linear_terms_for_m(data_xy, m):
    """For a fixed m, fit model (x^2 + u x + v)/m ≈ y using least squares."""
    RR = RealField(REAL_PREC)
    xs = [RR(x) for (x, _) in data_xy]
    ys = [RR(y) for (_, y) in data_xy]
    A = matrix(RR, [[x, RR(1)] for x in xs])
    b_vec = vector(RR, [RR(m)*y - x**2 for x, y in zip(xs, ys)])
    uv = A.solve_right(b_vec)
    u, v = uv[0], uv[1]
    residuals_sq = [((x**2 + u*x + v)/RR(m) - y)**2 for x, y in zip(xs, ys)]
    rmse = sqrt(sum(residuals_sq) / max(1, len(residuals_sq)))
    return (u, v, rmse)

def best_rational_model(data_xy, m_candidates=M_CANDIDATES):
    """Find m minimizing RMSE for model (x^2 + u x + v)/m."""
    best = None
    best_params = None
    for m in m_candidates:
        u, v, rmse = fit_linear_terms_for_m(data_xy, m)
        if best is None or rmse < best:
            best = rmse
            best_params = (m, u, v, rmse)
    return best_params

# ------------------------- Plotting ---------------------------

def plot_results_by_mod4(series_by_mod, title="AB(n) by n mod 4"):
    """Plot points and fitted asymptotic curves for each n mod 4."""
    var('x')
    G = Graphics()
    fits = {}

    for r, data in series_by_mod.items():
        if not data:
            continue
        color = COLORS.get(r, 'gray')

        G += list_plot(
            data,
            color=color,
            marker='o',
            size=30,
            legend_label=f"x ≡ {r} (mod 4)"
        )

        ns = [p[0] for p in data]
        n_min, n_max = min(ns), max(ns)

        m, u, v, rmse = best_rational_model(data)
        fits[r] = (m, u, v, rmse)

        model = (x^2 + u*x + v) / m
        G += plot(
            model,
            (x, n_min, n_max),
            color=color,
            linestyle='--',
            thickness=2,
            legend_label=f"~ x^2/{m} + O(x)"
        )

    G.show(axes_labels=['n', 'f(n)'], gridlines=True, legend_loc='upper left', title=title)
    return fits

# --------------------------- Main -----------------------------

def main():
    AB_by_n = collect_ab_pairs(4, N_MAX)
    data_length = [(n, len(AB_by_n[n])) for n in range(6, N_MAX + 1)]
    by_mod = {r: [] for r in (0, 1, 2, 3)}
    for n, size in data_length:
        by_mod[n % 4].append((n, size))

    fits = plot_results_by_mod4(by_mod, title="Sizes of AB(n) and Asymptotic Fits")

    print("Best rational models (x^2 + u x + v)/m by residue class (mod 4):")
    for r in (0, 1, 2, 3):
        if r not in fits:
            print(f"r={r}: no data for n ≤ {N_MAX}")
            continue
        m, u, v, rmse = fits[r]
        print(f"r={r}: m={m}, u≈{float(u):.6f}, v≈{float(v):.6f}, RMSE≈{float(rmse):.3f}")

if __name__ == '__main__':
    main()