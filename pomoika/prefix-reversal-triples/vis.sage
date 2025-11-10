import math
from sys import stdout

from sage.graphs.distances_all_pairs import diameter
from sage.groups.perm_gps.permgroup import PermutationGroup

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
#from sage.groups.perm_gps.permgroup import PermutationGroup


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

def make_pref_by_delta(n,delta):
    if(delta<0):
        return Prefix(n,n+delta)
    elif delta==0:
        return Prefix(n,n)
    else:
        return Prefix(n,delta)

def check(n,d1,d2):
    r1,r2,rn = make_pref_by_delta(n,d1),make_pref_by_delta(n,d2), Prefix(n,n)
    G_size = PermutationGroup([r1,r2,rn]).cardinality()
    Sn_size = SymmetricGroup(n).cardinality()
    return G_size == Sn_size

if __name__=="__main__":
    d2max=6
    for d2 in range(1,d2max+1):
        answers=[list(range(2,i)) for i in range(1,51)]
        for n in range(1,51):
            for d1 in range(2,n):
                answers[(n,d1)]=check(n,d1,d2)
                print(check(n,d1,d2),end='')


d={}
rangex=[100,0]
rangey=[100,0]
fname='inpn11.txt'
with open(fname,'r') as f:
    for line in f:
        fs=line.index(' ')
        d[int(line[:fs])]=['' if len(i)==0 else int(i.strip()) for i in line[line.index('[')+1:line.index(']')].split(',')]
        rangey[0]=min(rangey[0],int(line[:fs]))
        rangey[1]=max(rangey[0],int(line[:fs]))
        rangex[0]=min(rangex[0],min(d[int(line[:fs])]))
        rangex[1]=max(rangex[0],max(d[int(line[:fs])]))


ans=[[] for i in range(rangey[0],rangey[1]+1)]
for n in range(rangey[0],rangey[1]+1):
    i=n-rangey[0]
    for k in range(rangex[0],rangex[1]+1):
        if k in d[n]:
            ans[i].append(1)
        else:
            ans[i].append(0)

ans=ans[::-1]


harvest = np.array(ans)


def c(x):
    return {0:"white",1:"green"}[x]

fig, ax = plt.subplots()
im = ax.imshow(harvest,cmap="Greens")

y=list(range(rangey[0],rangey[1]+1))
x=list(range(rangex[0],rangex[1]+1))
# Show all ticks and label them with the respective list entries
ax.set_xticks(np.arange(len(x)), labels=x)
ax.set_yticks(np.arange(len(y)), labels=y[::-1])

ax.set_xlabel("k")
ax.set_ylabel("n")

# Rotate the tick labels and set their alignment.
# plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
#          rotation_mode="anchor")

# Loop over data dimensions and create text annotations.
# for i in range(len(xy)):
#     for j in range(len(xy)):
#         text = ax.text(j, i, str((i,j)),
#                        ha="center", va="center", color="red")

ax.set_title(f"Does r_k, r_{{n-{fname[4:fname.index('.')]}}}, r_n generate S_n?")
fig.tight_layout()
plt.show()

