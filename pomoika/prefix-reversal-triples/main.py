from products import *

# def is_good_ncycle()

def arr_to_str(arr):
    return ''.join([str(i) for i in arr])

def get_all_combos(generators, combo_length) -> list[tuple[str,int,Permutation]]:
    sz = combo_length
    gen_n = len(generators)
    ans = []
    hashes = set()
    n = generators[0].n
    for mask in range(gen_n**(sz)):
        inds = [(mask//(gen_n**i))%gen_n for i in range(sz)]
        prod = Prefix(n,1) # unit perm
        for ind in inds:
            prod *= generators[ind]

        if(prod.p not in hashes):
            hashes.add(prod.p)
            ans.append((arr_to_str(inds),1,prod))
    return ans

def bake(generators, recipe):
    ans = Prefix(generators[0].n,1)
    for c in recipe:
        ans*=generators[int(c)]
    return ans

def verify(generators, ext_perms):
    for e_perm in ext_perms:
        res1 = bake(generators,e_perm[0])**e_perm[1]
        if(res1.p!=e_perm[2].p):
            print("BAD")
            print(e_perm)
            print(res1)
            exit(0)

class BreakLoop(Exception):
    pass

def ext_perms_to_all_unique_powers(perms:list[tuple[str,int,Permutation]]) -> list[tuple[str,int,Permutation]]:
    s = set()
    ans = []
    for perm in perms:
        powers = perm[2].get_all_powers()
        for pwn,power in enumerate(powers):
            if power.p not in s:
                s.add(power.p)
                ans.append((perm[0],pwn+1,power))
    return ans



def find_LR(n,pref_mx=2,pc_mx=6,suff_mx=2):
    """
    Given r2, rn. Try to find k-s where r2 + rk + rn give L or R in from below.
    Prefx + (PowerCombo)**q + suffix?
    """
    for k in range(n-4,n-2):
        # print('hey')
        generators = [Prefix(n,1) ,Prefix(n,k), Prefix(n,n-1), Prefix(n,n)]
        
        pref_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, pref_mx))
        mid_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, pc_mx))
        suff_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, suff_mx))
        verify(generators,suff_combos)
        for p in pref_combos:
            for m in mid_combos:
                for s in suff_combos:
                    if is_good_transposition(p[2]*m[2]*s[2]):
                        pp, mm, ss = bake(generators,p[0]),bake(generators,m[0]),bake(generators,s[0])
                        print(n,k,p[0],m[0],s[0], p[1], m[1], s[1])


# 10 10
# 323212


n=16
# k=n-4
# p, m ,s = Prefix(n,k), Prefix(n,n-1)*Prefix(n,k), Prefix(n,k)
# print((p*(m**13)*s).to_actual_cycles())
# find_LR(n)

for n in range(6,25,2):
    k=n-4
    gens = [Prefix(n,1),Prefix(n,k),Prefix(n,n-1),Prefix(n,n)]
    p,m,s = bake(gens,'10'), bake(gens,'323212'), bake(gens,'10')
    guess = p*(m**(n-3))*s
    print(n, list(guess.p), list((gens[3]*gens[2]).p))

# n-4, n-1, n