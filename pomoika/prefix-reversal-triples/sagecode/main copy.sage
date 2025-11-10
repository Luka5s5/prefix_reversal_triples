from sage.groups.perm_gps.permgroup import PermutationGroup
from sage.graphs.distances_all_pairs import diameter
import math
from sys import stdout

def perm_pow(self,a):
        if(a==1): return self
        if(a==0): return Permutation(self.n)
        if(a%2==0):
            b=self**(a//2)
            return b*b
        else:
            return self**(a-1)*self

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

def Prefix(n,k):
    l=[i+1 for i in range(n)]
    l=l[:k][::-1]+l[k:]
    return Permutation(list(tuple(l)))

def arr_to_str(arr):
    return ''.join([str(i) for i in arr])


def bake(generators, recipe):
    ans = Prefix(len(generators[0]),1)
    for c in recipe:
        ans*=generators[int(c)]
    return ans

class BreakLoop(Exception):
    pass

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
    return signature.count(2) == 1 and all([i%2==1 or (i==2 and math.gcd(max(cyc[0],cyc[1])-min(cyc[0],cyc[1]),n)==1) for i,cyc in zip(signature,p.to_cycles())])

def bfs_big_2(n):
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

def find_good_power(p):
    return math.prod([len(i) for i in p.to_cycles() if len(i)!=2])

def make_pref_by_delta(n,delta):
    if(delta<0):
        return Prefix(n,n+delta)
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
        _,rec,perm = bfs_big_2(n)
        if(rec not in seen_recipes):
            print(n,"NEW!",rec)
            seen_recipes[rec] = n
        else:
            print(n, 'first_seen', seen_recipes[rec])
    return seen_recipes

def bfs_LR(gens,n,start=''):
    seen = set()
    q = Queue()
    q.put((start,bake(gens,start)))
    while(q.qsize() != 0):
        v = q.get()
        if(is_power_good(v[1])):
                return (n,v[0],v[1])
        for i,g in enumerate(gens):
            to = v[1]*g
            if(tuple(to) not in seen):
                seen.add(tuple(to))
                q.put((v[0]+str(i),to))
    return (-1,-1,-1)

def find_shortest_recipes_LR(delta,start_rec = '',nmin=4,nmax=100,nstep=1):
    seen_recipes = {}
    for n in range(nmin,nmax,nstep):
        genss = [make_pref_by_delta(n,delta),Prefix(n,n-1)*Prefix(n,n),Prefix(n,n)*Prefix(n,n-1)]
        try:
            for rec in seen_recipes.keys():
                if(is_power_good(bake(genss,rec))):
                    print(n, 'first_seen', seen_recipes[rec])
                    raise BreakLoop
        except:
            continue
        rc,rec,perm = bfs_LR(genss,n,start_rec)
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

def find_conjecture(nmax):
    print("n\tk's")
    for n in range(3,nmax):
        Sn_card = SymmetricGroup(n).cardinality()
        good_ks=[]
        for k in range(2,n-1):
            gens = [Prefix(n,k),Prefix(n,n-1),Prefix(n,n)]
            G = PermutationGroup(gens)
            if(Sn_card == G.cardinality()):
                good_ks.append(k)
        print(n,good_ks,sep='\t')

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