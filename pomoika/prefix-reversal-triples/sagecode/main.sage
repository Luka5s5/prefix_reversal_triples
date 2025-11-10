from sage.groups.perm_gps.permgroup import PermutationGroup
from sage.graphs.distances_all_pairs import diameter
import math
from sys import stdout

def is_good_transposition(p):
    n=len(p)
    sign = [len(i) for i in p.to_cycles()]
    sign.sort()
    return (sign[-1]==2 and sign.count(1)==n-2 and any([len(i)==2 and math.gcd(i[1]-i[0],n)==1 for i in p.to_cycles()]))

def perm_pow(self,a):
        if(a==1): return self
        if(a==0): return Permutation(self.n)
        if(a%2==0):
            b=self**(a//2)
            return b*b
        else:
            return self**(a-1)*self

def signature(self):
    return list(sorted([len(i) for i in self.to_cycles()]))

def get_all_powers(self):
        perm = self
        perm *= perm
        powers = [self,perm]
        while True:
            perm*=self
            if tuple(self)==tuple(perm):
                break
            powers.append(perm)
        return powers
    


Permutation.__pow__ = perm_pow
Permutation.get_all_powers = get_all_powers
Permutation.signature = signature

def Prefix(n,k):
    l=[i+1 for i in range(n)]
    l=l[:k][::-1]+l[k:]
    return Permutation(list(tuple(l)))

def is_n2(p,n):
    return Prefix(n,n-2) == p

def arr_to_str(arr):
    return ''.join([str(i) for i in arr])

def get_all_combos(generators, combo_length) -> list[tuple[str,int,Permutation]]:
    sz = combo_length
    gen_n = len(generators)
    ans = []
    hashes = set()
    n = len(generators[0])
    for mask in range(gen_n**(sz)):
        inds = [(mask//(gen_n**i))%gen_n for i in range(sz)]
        prod = Prefix(n,1) # unit perm
        for ind in inds:
            prod *= generators[ind]

        if(tuple(prod) not in hashes):
            hashes.add(tuple(prod))
            ans.append((arr_to_str(inds),1,prod))
    return ans

def bake(generators, recipe):
    # print(generators[0],len(generators[0]))
    ans = Prefix(len(generators[0]),1)
    for c in recipe:
        ans*=generators[int(c)]
    #print(ans)
    return ans

def verify(generators, ext_perms):
    for e_perm in ext_perms:
        # print(bake(generators,e_perm[0]))
        res1 = bake(generators,e_perm[0])**e_perm[1]
        # print("!", res1, e_perm)
        if(tuple(res1)!=tuple(e_perm[2])):
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
            if tuple(power) not in s:
                s.add(tuple(power))
                ans.append((perm[0],pwn+1,power))
    return ans



def find_LR(n,pref_mx=0,pc_mx=6,suff_mx=0):
    """
    Given r2, rn. Try to find k-s where r2 + rk + rn give L or R in from below.
    Prefx + (PowerCombo)**q + suffix?
    """
    for k in range(2,n-1):
        # print('hey')
        generators = [Prefix(n,1) ,Prefix(n,k), Prefix(n,n-1), Prefix(n,n)]
        generators.append(bake(generators,'3212'))
        pref_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, pref_mx))
        mid_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, pc_mx))
        suff_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, suff_mx))
        verify(generators,suff_combos)
        for p in pref_combos:
            for m in mid_combos:
                for s in suff_combos:
                    if is_good_transposition(p[2]*m[2]*s[2]) and p[1] == 1 and s[1] == 1 and m[1] == n-3:
                        pp, mm, ss = bake(generators,p[0]),bake(generators,m[0]),bake(generators,s[0])
                        print(n,k,p[0],m[0],s[0], p[1], m[1], s[1])
                        return 1
    return 0

def find_all_ks_with_recipes(n,pref_mx=0,pc_mx=7,suff_mx=0):
    """
    Given r2, rn. Try to find k-s where r2 + rk + rn give L or R in from below.
    Prefx + (PowerCombo)**q + suffix?
    """
    for k in range(2,n-1):
        # print('hey')
        generators = [Prefix(n,1) ,Prefix(n,k), Prefix(n,n-1), Prefix(n,n)]
        generators.append(bake(generators,'2321'))
        generators.append(bake(generators,'43'))
        generators.append(bake(generators,'54'))
        mid_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, pc_mx))
        try:
            for m in mid_combos:
                if is_good_transposition(m[2]):
                    print(n,k,m[0],m[1])
                    raise BreakLoop
        except BreakLoop:
            pass
        else:
            print(k,'not found')
    return 0

def find_all_ks_with_recipes_odd(n,pref_mx=0,pc_mx=8,suff_mx=0):
    """
    Given r2, rn. Try to find k-s where r2 + rk + rn give L or R in from below.
    Prefx + (PowerCombo)**q + suffix?
    """
    for k in range(6,n-4,2):
        # print('hey')
        generators = [Prefix(n,1) ,Prefix(n,k), Prefix(n,n-1), Prefix(n,n)]
        generators.append(bake(generators,'3212'))
        mid_combos = ext_perms_to_all_unique_powers(get_all_combos(generators, pc_mx))
        try:
            for m in mid_combos:
                if is_n2(m[2],n):
                    print(n,k,m[0],m[1])
                    raise BreakLoop
        except BreakLoop:
            pass
        else:
            print(k,'not found')
    return 0

def find_all_big_complements():
    for n in range(6,101):
        working = []
        for k in range(2,n-1):
            generators = [Prefix(n,k),Prefix(n,n-1),Prefix(n,n)]
            G = PermutationGroup(generators)
            Sn = SymmetricGroup(n)
            if(G.cardinality() == Sn.cardinality()):
                working.append(k)
        print(n,working)



def check_hyp_any_works():
    n=19+4*3
    find_all_ks_with_recipes(n)

def check_hyp_2_works():
    n=12
    find_all_ks_with_recipes_odd(n)

def find_rec_for_6(mx_len=6):
    for n in range(33,40,2):
        k = 6
        gens = [Prefix(n,1), Prefix(n,k), Prefix(n,n-1), Prefix(n,n)]
        #gens.append(bake(gens,'31'))
        gens.append(bake(gens,'32'))
        com = ext_perms_to_all_unique_powers(get_all_combos(gens,8))
        for c in com:
            if is_good_transposition(c[2]):
                print(n, c)
                #break
        else:
            print(n,'not found')

def check_recipe_for_6():
    k = 6
    for n in range(9,101,4):
        gens = [Prefix(n,1), Prefix(n,k), Prefix(n,n-1), Prefix(n,n)]
        gens.append(bake(gens,'32'))
        L, R = gens[2]*gens[3], gens[3]*gens[2]
        p1 = bake(gens,'14144123')
        print(n,[len(i) for i in p1.to_cycles()])
        print(n,[len(i) for i in (p1**((n-3)//2)).to_cycles()])
        #print(n,p1.to_cycles())
        #print((p1**(n-6-((n-1)//2-4))).to_cycles())
        p2 = gens[4]
        G = PermutationGroup([p1**(15),p2])
        Sn = SymmetricGroup(n)
        if(G.cardinality() == Sn.cardinality()):
            print(n, 'works')
        else:
            print(n, 'doesnt')


def compute_diameters():
    for n in range(9,11):
        candidate_names = ["2","n-3","4","6","n-4"]
        candidates = [Prefix(n,2),Prefix(n-3,2),Prefix(n,4),Prefix(n,6),Prefix(n,n-4)]
        big_2 = [Prefix(n,n-1)*Prefix(n,n),Prefix(n,n)*Prefix(n,n-1)]
        for i,candidate in enumerate(candidates):
            gens = [candidate] + big_2
            G = PermutationGroup(gens)
            Sn = SymmetricGroup(n)
            if(Sn.cardinality() != G.cardinality()):
                print(n,candidate_names[i],'is bad')
                continue
            print(n, candidate_names[i], diameter(G.cayley_graph().to_undirected(), algorithm='multi-sweep'))
            sys.stdout.flush() 


from queue import Queue
import math
def is_power_good(p):
    n = len(p)
    signature = [len(i) for i in p.to_cycles()]
    if signature.count(2) == 1 and all([i%2==1 or (i==2 and math.gcd(max(cyc[0],cyc[1])-min(cyc[0],cyc[1]),n)==1) for i,cyc in zip(signature,p.to_cycles())]):
        #print(p.to_cycles())
        return True
    else:
        return False


def find_shortest_good_shit(n):
    gens = [Prefix(n,6),Prefix(n,n-1),Prefix(n,n)]
    seen = set()
    q = Queue()
    q.put(('',Prefix(n,1)))
    while(True):
        v = q.get()
        for i,g in enumerate(gens):
            to = v[1]*g
            if(to not in seen):
                seen.add(to)
                q.put((v[0]+str(i),to))
            if(is_power_good(to)):
                return (n,v[0]+str(i),to)
                #print(n,v[0]+str(i))
                #return

'''
13 : 010210212
20 : 01021021212
22 : 01201210212
24 : 01020121212
'''

def find_good_power(p):
    return math.prod([len(i) for i in p.to_cycles() if len(i)!=2])
    return math.lcm(*[len(i) for i in p.to_cycles() if len(i)!=2])

def make_pref_by_delta(n,delta):
    if(delta<0):
        return Prefix(n,n+delta)
    elif delta==0:
        return Prefix(n,n)
    else:
        return Prefix(n,delta)

def check_recipes(delta,recipes,labels,nmin,nmax,nstep):
    ret = {}
    for n in range(nmin,nmax,nstep):
        gens = [make_pref_by_delta(n,delta),Prefix(n,n-1),Prefix(n,n)]
        results = []
        for ind,recipe in enumerate(recipes):
            res = bake(gens,recipe)
            if(not is_power_good(res)):
                continue
            results.append((labels[ind],find_good_power(res)))
            if(labels[ind] in ret):
                ret[labels[ind]].append(n)
            else:
                ret[labels[ind]] = [n]
        print(n,results)
    return ret

def find_shortest_recipes(delta,nmin,nmax,nstep):
    print("FUCK")
    seen_recipes = {}
    for n in range(nmin,nmax,nstep):
        gens = [make_pref_by_delta(n,delta),Prefix(n,n-1),Prefix(n,n)]
        try:
            for rec in seen_recipes.keys():
                if(is_power_good(bake(gens,rec))):
                    print(n, 'first_seen', seen_recipes[rec])
                    raise BreakLoop
        except:
            continue
        _,rec,perm = find_shortest_good_shit(n)
        if(rec not in seen_recipes):
            print(n,"NEW!",rec)
            seen_recipes[rec] = n
        else:
            print(n, 'first_seen', seen_recipes[rec])
    return seen_recipes


def is_power_good_nminus2(p):
    n = len(p)
    signature = [len(i) for i in p.to_cycles()]
    if signature.count(2) == 1 and all([i%2==1 or (i==2 and max(cyc[0],cyc[1])-min(cyc[0],cyc[1])==2) for i,cyc in zip(signature,p.to_cycles())]):
        #print(p.to_cycles())
        return True
    else:
        return False

def find_shortest_good_shit_LR(gens,n,start=''):
    seen = set()
    q = Queue()
    q.put((start,bake(gens,start)))
    while(q.qsize() != 0):
        v = q.get()
        if(is_power_good_nminus2(v[1])):
                return (n,v[0],v[1])
        for i,g in enumerate(gens):
            to = v[1]*g
            if(tuple(to) not in seen):
                seen.add(tuple(to))
                q.put((v[0]+str(i),to))
    return (-1,-1,-1)

GLOBCNT=0

def bfs(gens,start,checker):
    seen = set()
    q = Queue()
    q.put(("",start))
    global GLOBCNT
    while(q.qsize()!=0):
        v=q.get()
        '''
        GLOBCNT+=1
        if(GLOBCNT==10000):
            print(v[0],v[1].to_cycles())
            GLOBCNT=1
        '''
        if(checker(v[1])):
            return (v[0],v[1])
        for i,g in enumerate(gens):
            to=v[1]*g
            if(tuple(to) not in seen):
                seen.add(tuple(to))
                q.put((v[0]+str(i),to))
    return ("-",0)

def find_shortest_recipes_general(deltas,checker,gen_recs=[],start_rec='',nmin=4,nmax=100,nstep=1):
    if len(gen_recs) != len(deltas):
        gen_recs=list(range(len(deltas)))
    
    seen_recipes = {}
    for n in range(nmin,nmax,nstep):
        basis = [make_pref_by_delta(n,i) for i in deltas]
        genss = [bake(basis,r) for r in gen_recs]
        try:
            for rec in seen_recipes.keys():
                if(checker(bake(genss,rec))):
                    print(n, 'first_seen', seen_recipes[rec])
                    raise BreakLoop
        except:
            continue
        rec,perm = bfs(genss,bake(genss,start_rec),checker)
        if(rec=="-"):
            print(n,'fuck')
            continue
        if(rec not in seen_recipes):
            print(n,"NEW!",rec)
            seen_recipes[rec] = n
        else:
            print(n, 'first_seen', seen_recipes[rec])
    return seen_recipes

def is_trans_and_odds(p):
    n = len(p)
    signature = [len(i) for i in p.to_cycles()]
    if signature.count(2) == 1 and all([(i%2==1) or (i==2) for i,cyc in zip(signature,p.to_cycles())]):
        return True
    else:
        return False

def is_trans_and_odds(p):
    n = len(p)
    signature = [len(i) for i in p.to_cycles()]
    if signature.count(2) == 1 and all([(i%2==1) or (i==2) for i,cyc in zip(signature,p.to_cycles())]):
        return True
    else:
        return False

def are_adjacent_in_this_cycle(cycle):
    def adj(p):
        if not is_trans_and_odds(p):
            return False
        c = cycle.to_cycles()[0]
        p = [q for q in p.to_cycles() if len(q)==2][0]
        i1, i2 = c.index(p[0]), c.index(p[1])
        if(abs(i1-i2)==1 or (i1==len(c)-1 and i2==0) or (i2==len(c)-1 and i2==0)):
            return True
        else:
            return False
    return adj

def are_adj_in_this_recipe_cycle(gens,recipe):
    cycle = bake(gens,recipe)
    def adj(p):
        if not is_trans_and_odds(p):
            return False
        c = cycle.to_cycles()[0]
        p = [q for q in p.to_cycles() if len(q)==2][0]
        i1, i2 = c.index(p[0]), c.index(p[1])
        if(abs(i1-i2)==1 or (i1==len(c)-1 and i2==0) or (i2==len(c)-1 and i2==0)):
            return True
        else:
            return False
    return adj

def find_shortest_recipes_cycle(deltas,cycle_recipe,gen_recs=[],start_rec='',nmin=4,nmax=100,nstep=1):
    if len(gen_recs) != len(deltas):
        gen_recs=list(range(len(deltas)))
    
    seen_recipes = {}
    for n in range(nmin,nmax,nstep):
        basis = [make_pref_by_delta(n,i) for i in deltas]
        genss = [bake(basis,r) for r in gen_recs]
        cycle = bake(genss,cycle_recipe)
        checker = are_adjacent_in_this_cycle(cycle)
        try:
            for rec in seen_recipes.keys():
                if(checker(bake(genss,rec))):
                    print(n, 'first_seen', seen_recipes[rec])
                    raise BreakLoop
        except:
            continue
        rec,perm = bfs(genss,bake(genss,start_rec),checker)
        if(rec=="-"):
            print(n,'fuck')
            continue
        if(rec not in seen_recipes):
            print(n,"NEW!",rec)
            seen_recipes[rec] = n
        else:
            print(n, 'first_seen', seen_recipes[rec])
    return seen_recipes

def find_shortest_recipes_LR(delta,start_rec = '',nmin=4,nmax=100,nstep=1):
    seen_recipes = {}
    for n in range(nmin,nmax,nstep):
        genss = [make_pref_by_delta(n,delta),Prefix(n,n-2)*Prefix(n,n),Prefix(n,n)*Prefix(n,n-2)]
        try:
            for rec in seen_recipes.keys():
                if(is_power_good_nminus2(bake(genss,rec))):
                    print(n, 'first_seen', seen_recipes[rec])
                    raise BreakLoop
        except:
            continue
        rc,rec,perm = find_shortest_good_shit_LR(genss,n,start_rec)
        if(rc==-1):
            print(n,'fuck')
            continue
        if(rec not in seen_recipes):
            print(n,"NEW!",rec)
            seen_recipes[rec] = n
        else:
            print(n, 'first_seen', seen_recipes[rec])
    return seen_recipes

def check_recipes_LR(delta,recipes,labels,nmin,nmax,nstep):
    ret = {}
    for n in range(nmin,nmax,nstep):
        gens = [make_pref_by_delta(n,delta),Prefix(n,n-1)*Prefix(n,n),Prefix(n,n)*Prefix(n,n-1)]
        results = []
        for ind,recipe in enumerate(recipes):
            res = bake(gens,recipe)
            #print(res.to_cycles())
            if(not is_power_good(res)):
                continue
            results.append((labels[ind],find_good_power(res)))
            if(labels[ind] in ret):
                ret[labels[ind]].append(n)
            else:
                ret[labels[ind]] = [n]
        print(n,results)
    return ret

def find_smallest_power(delta,start_rec = '',nmin=4,nmax=100,nstep=1):
    for n in range(nmin,nmax,nstep):
        gens = [make_pref_by_delta(n,delta),Prefix(n,n-1)*Prefix(n,n),Prefix(n,n)*Prefix(n,n-1)]
        start = bake(gens,start_rec)
        if(is_power_good(start*bake(gens,'0110'))):
            print(n,'0110')
            continue
        if(is_power_good(start*bake(gens,'0220'))):
            print(n,'0220')
            continue
        cnt=0
        while(not is_power_good(start) and cnt<5000):
            start*=gens[2]
            cnt+=1
        
        if(cnt>=5000):
            print(n,'notfound')
            n,rec,per = find_shortest_good_shit_LR(gens,n,start_rec)
            print(n,rec)
        else:
            print(n,cnt,start_rec+'2'*cnt)


def find_conjecture(nmin,nmax,delta=-1):
    print("conjectures for r_k r_n"+str(delta)+" r_n")
    print("n\tk's")
    for n in range(nmin,nmax):
        Sn_card = SymmetricGroup(n).cardinality()
        good_ks=[]
        for k in range(2,n-1):
            gens = [Prefix(n,k),make_pref_by_delta(n,delta),Prefix(n,n)]
            G = PermutationGroup(gens)
            if(Sn_card == G.cardinality()):
                good_ks.append(k)
        print(n,good_ks,sep='\t',flush=True)

def find_conjecture_kplus(nmin,nmax):
    print("conjectures for r_k-1 r_k r_n")
    print("n\tk's")
    for n in range(nmin,nmax):
        Sn_card = SymmetricGroup(n).cardinality()
        good_ks=[]
        for k in range(3,n-1):
            gens = [Prefix(n,k-1),Prefix(n,k),Prefix(n,n)]
            G = PermutationGroup(gens)
            if(Sn_card == G.cardinality()):
                good_ks.append(k)
        print(n,good_ks,sep='\t',flush=True)


def find_conjecture_top(nmax,delta=2):
    print('top conjecture for k:',delta)
    print("n\tn-k's")
    for n in range(3,nmax):
        Sn_card = SymmetricGroup(n).cardinality()
        good_ks=[]
        for sub in range(1,n-1):
            gens = [make_pref_by_delta(n,delta),Prefix(n,n-sub),Prefix(n,n)]
            G = PermutationGroup(gens)
            if(Sn_card == G.cardinality()):
                good_ks.append(sub)
        print(n,good_ks,sep='\t')

def tos(p):
    return '"'+''.join([str(i) for i in list(p)])+'"'

def is_n_cycle(p):
    return (len(p) == list(sorted(p.signature()))[0])

def is_default_n_cycle(p):
    return p.to_cycles()==[tuple(i+1 for i in range(len(p)))]

def is_transposition(p):
    c=p.to_cycles()
    return list(sorted(c.signature())) == ((len(c)-1)*[1])+[2]




def wtf(f):
    return f


def has_adjacent(p):
    p = p.to_cycles()
    if(len(p)>1):
        return False
    p=p[0]
    n=len(p)
    pairs=[(p[i],p[(i+1)%n]) for i in range(n)]
    return any([abs(j-i)==1 for i,j in pairs])

def bfs_growth(gens,start):
    seen = set()
    q = Queue()
    q.put((0,start))
    ans={}
    while(q.qsize()!=0):
        v=q.get()
        for g in gens:
            to=v[1]*g
            if(tuple(to) not in seen):
                if v[0] in ans:
                    ans[v[0]]+=1
                else:
                    ans[v[0]]=1
                seen.add(tuple(to))
                q.put((v[0]+1,to))
    return ans

def compute_growth():
    for n in range(8,10):
        Sn_card = SymmetricGroup(n).cardinality()
        for k in range(2,n-1):
            gens = [Prefix(n,k),Prefix(n,n-1),Prefix(n,n)]
            if(Sn_card != PermutationGroup(gens).cardinality()):
                continue
            d = bfs_growth(gens,Prefix(n,1))
            print(n,k,list(dict(bfs_growth(gens,Prefix(n,1))).values()))


if __name__=="__main__":
    for n in range(4,101):
        Sn_card = SymmetricGroup(n).cardinality()
        for b in range(2,n):
            for a in range(2,b):
                gens = [Prefix(n,a),Prefix(n,b),Prefix(n,n)]
                prefix_group_card = PermutationGroup(gens).cardinality()
                print((a,b,n,Sn_card//prefix_group_card,))
    exit(0)

    for n in range(6,500):
        for k in range((n//2+1 if (n//2)%2!=0 else n//2+2),n,2):
            print(n,k)
            gens = [Prefix(n,k),Prefix(n,k-1),Prefix(n,n)]
            #print('012',bake(gens,'012').to_cycles())
            #print('121',bake(gens,'121').to_cycles())
            #print('021',bake(gens,'021').to_cycles())
            print([i for i in bake(gens,'012012121021').to_cycles() if len(i)>=2])
    exit(0)
    find_conjecture_kplus(4,200)
    exit(0)
    import sys
    print(sys.argv)
    find_conjecture(6,int(float(sys.argv[2])),-int(float(sys.argv[1])))
    exit(0)
    # compute_growth()
    # exit(0)
    # find_conjecture(71,151,-11)
    # exit(0)
    for n in range(1,20):
       print(n,":")
       [print(i.to_cycles()) for i in (Prefix(n,n)*Prefix(n,n-2)).get_all_powers()]
       print()
    exit(0)
    find_conjecture_top(101,5)
    exit(0)
    find_shortest_recipes_general([9,-2,0],is_power_good_nminus2,['0','12','21'],'',6,100,2)
    exit(0)
    for n in range(6,20,2):
        for k in range(2,n-3,2):
            gens = [Prefix(n,k), Prefix(n,n-2)*Prefix(n,n) , Prefix(n,n)*Prefix(n,n-2)]
            print(n,k,(bake(gens,"0"+"2"*2)).to_cycles(),"\n",(bake(gens,"0"+"2"*3)).to_cycles())
            #print(n,k,[cycle if len(cycle) in (n,2) else len(cycle) for cycle in bake(gens,"1"*(k//2)+"0").to_cycles() if len(cycle)!=1])
    exit(0)
    k=8
    find_shortest_recipes_cycle([k,-2,0],'01111',["0","12","21"],'',7,100,2)
    exit(0)
    for k in range(2,40,2):
        for n in range(k+3,100,2):
            gens = [Prefix(n,k),Prefix(n,n-2)*Prefix(n,n),Prefix(n,n)*Prefix(n,n-2)]
            print(n,k,(bake(gens,"0"+(k//2)*"1")).to_cycles())
            print()
    exit(0)
    '''
    a=3
    for n in range(2,20,1):
        print(n,[i.signature() for i in (Prefix(n,n-a)*Prefix(n,n)).get_all_powers()])
        print()
    exit(0)
    find_conjecture(101)
    #exit(0)
    n=20
    k=15
    Sn_size=SymmetricGroup(n).cardinality()
    gens = [Prefix(n,k),Prefix(n,n-2),Prefix(n,n)]
    print((gens[1]*gens[2]).to_cycles())
    for l in range(7):
        print(l,(bake(gens,"0"+"12"*l)).to_cycles())
    exit(0)
    our_size=PermutationGroup([gens[1]*gens[2],bake(gens,"0"+"12"*6)**(n-3)]).cardinality()
    
    print((bake(gens,"0"+"12"*6)**(n-3)).to_cycles())
    print(Sn_size,our_size)
    exit(0)
    '''
    
    for n in range(40,41,2):
        rn2 = Prefix(n,n-2)
        rn = Prefix(n,n)
        gens=[Prefix(n,11),Prefix(n,n-2),Prefix(n,n)]
        for l in range(6):
            print(l,(bake(gens,"0"+"12"*l).to_cycles()))
    exit(0)
    
    #find_conjecture(101)
    '''
    find_shortest_recipes_LR(9,'',6,100,2)
    for n in range(12,100,2):
        gens = [Prefix(n,9),(Prefix(n,n-2)*Prefix(n,n)),Prefix(n,n)*Prefix(n,n-2)]
        L,R = gens[1], gens[2]
        print(n,(bake(gens,"0111")).to_cycles())
        #print(n, (bake(gens,"010102022")).to_cycles(), [len(i) for i in (R*R*bake(gens,"010102022")*L*L).to_cycles()])
    '''
        #for k in range(3,n-2,2):
        #    gens = [Prefix(n,k),(Prefix(n,n-2)*Prefix(n,n)),Prefix(n,n)*Prefix(n,n-2)]
        #    print(n,k,[i for i in (bake(gens,"0"+"1"*((k-2)//2))).to_cycles() if len(i)%2==0])
'''
def bfs(gens:list[Permutation],init:Permutation,looking_for:Callable[[Permutation],bool]) -> [string]:
    now_layer = {init}
    while(len(now_layer) != 0):
        now
'''

'''
if __name__ == "__main__":
    compute_diameters()
    find_conjecture(101)
    exit(0)
    find_shortest_recipes_LR(4,'',7,50,4)
    exit(0)
    recipe = '01011102222'
    for n in range(13,50,2):
        L, R = Prefix(n,n)*Prefix(n-1,n),Prefix(n-1,n)*Prefix(n,n)
        gens = [Prefix(10,n),L,R]
        print((R**7)*(bake(gens,recipe)**(35))*(L**7).to_cycles())
    exit(0)
'''
