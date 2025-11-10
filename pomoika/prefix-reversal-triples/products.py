import math

class Permutation:
    p = ()
    n = 0
    def __init__(self,n,p=()):
        self.n = n
        if(p==()):
            self.p = tuple([i+1 for i in range(n)])
        else:
            self.p = p

    def __str__(self):
        return str(self.p)

    def __repr__(self):
        return str(self)

    def __hash__(self):
        return hash(str(self))

    def __getitem__(self, key):
        return self.p[key]

    def __mul__(self,other):
        if(isinstance(other,Permutation)):
            if(other.n!=self.n):
                raise Exception("Permutations of different sizes")
            ans = Permutation(self.n)
            ans.p = tuple([self[other[i]-1] for i in range(self.n)])
            ans.n = self.n
            return ans
        else:
            raise Exception("Invalid type in Permutation product")
    
    def __pow__(self,a):
        if not isinstance(a,int):
            raise Exception("Bad exponent for Permutation")
        if(a==1): return self
        if(a==0): return Permutation(self.n)
        if(a%2==0):
            b=self**(a//2)
            return b*b
        else:
            return self**(a-1)*self
        
    def to_cycles(self):
        ans = ""
        n=self.n
        used=[False for i in range(n)]
        for i in range(n):
            if used[i]:
                continue
            used[i]=True
            ans+="("+str(i+1)
            to=self[i]-1
            while(to!=i):
                used[to]=True
                ans+=" "+str(to+1)
                to=self[to]-1
            ans+=") "
        return ans
    
    def get_signature(self):
        lengths=[]
        n=self.n
        used=[False for i in range(n)]
        for i in range(n):
            if used[i]:
                continue
            l=1
            used[i]=True
            to=self[i]-1
            while(to!=i):
                l+=1
                used[to]=True
                to=self[to]-1
            lengths.append(l)
        lengths.sort()
        return tuple(lengths)

    def to_actual_cycles(self):
        ans = []
        n=self.n
        used=[False for i in range(n)]
        for i in range(n):
            if used[i]:
                continue
            used[i]=True
            tans = []
            tans.append(i+1)
            to=self[i]-1
            while(to!=i):
                used[to]=True
                tans.append(to+1)
                to=self[to]-1
            ans.append(tuple(tans))
        ans.sort()
        return ans
    
    def get_all_powers(self):
        perm = Permutation(self.n,self.p)
        perm *= perm
        powers = [Permutation(self.n,self.p),Permutation(perm.n,perm.p)]
        while True:
            perm*=self
            if self.p==perm.p:
                break
            powers.append(Permutation(perm.n,perm.p))
        return powers
        



def Prefix(n,k):
    l=[i+1 for i in range(n)]
    l=l[:k][::-1]+l[k:]
    return Permutation(n,tuple(l))

def is_1k_transposition(p):
    cycles = p.to_actual_cycles()
    return len(cycles[0])==2 and 1 in cycles[0] and all([math.gcd(len(i),2)==1 for i in cycles[1:]])


def find_smallest_good_product(generators,checker,start=1,finish=20):
    n=generators[0].n
    gen_n = len(generators)
    maskl=start-1
    while maskl<=finish:
        print("nowlen is ",maskl)
        maskl+=1
        masknum = gen_n**maskl-1
        while(masknum!=-1):
            mask=tuple((masknum//gen_n**i)%gen_n for i in range(maskl))
            masknum-=1
            product = Permutation(n)
            for ind in mask:
                product*=generators[ind]
            print(product.to_actual_cycles()) 
            if checker(product):
                return mask
    return ()

def q_find_smallest_good_product(generators,checker):
    n=generators[0].n
    used_perms = {Permutation(n).p:0}
    now_perms = {(Permutation(n),""):0}
    now_len=0
    while(len(now_perms)!=0):
        # print("now len is ",now_len)

        new_perms={}
        for perm,rec in now_perms:
            for ind,g in enumerate(generators):
                np=perm*g
                if np.p in used_perms: continue
                used_perms[np.p]=0
                new_perms[(perm*g,rec+str(ind))]=0
        for p,r in now_perms:
            if checker(p):
                return r
        now_perms=new_perms
        now_len+=1
        # if(now_len==2 or now_len==4): print(new_perms)
    return str(len(used_perms))+":("

def is_n_or_n1_cycle(p):
    n=p.n
    sign = [len(i) for i in p.to_actual_cycles()]
    return any([i in sign for i in [n,n-1]]) and all([i in (1,n-1,n) for i in sign])

def is_good_transposition(p):
    n=p.n
    sign = p.get_signature()
    return (sign[-1]==2 and sign.count(1)==n-2 and any([len(i)==2 and math.gcd(i[1]-i[0],n)==1 for i in p.to_actual_cycles()]))

def is_transposition(p):
    n=p.n
    sign=p.get_signature()
    return (sign[-1]==2 and sign.count(1)==n-2)

def compute(revs,rec):
    n=revs[0].n
    ans=Permutation(n)
    for c in rec: ans*=revs[int(c)]
    return ans

def is_12(p):
    n=p.n
    sign=p.get_signature()
    return (sign[-1]==2 and sign.count(1)==n-2 and (1,2) in p.to_actual_cycles())

def find_good_powers(gen,checker):
    p=gen
    used={}
    power=1
    good=[]
    while(p.p not in used):
        if checker(p):
            return (p,power)
        used[p.p]=power
        power+=1
        p*=gen
    return (None,None)

def make_from_cycles(cycles,n):
    p=Permutation(n)
    tmp=[i+1 for i in range(n)]
    for cycle in cycles:
        lcycle=list(cycle)+[cycle[0]]
        for i in range(len(cycle)):
            tmp[lcycle[i]-1]=lcycle[i+1]
    p.p=tuple(tmp)
    return p

def is_13(p):
    n=p.n
    sign=p.get_signature()
    return (sign[-1]==2 and sign.count(1)==n-2 and (1,3) in p.to_actual_cycles())

def find_good_pref_powers(gen,checker,gens,mxlen):
    n=gens[0].n
    for l in range(mxlen):
            # print("pref_l is now", l)
            mask_num=len(gens)**l-1
            while(mask_num>=0):
                mask_inds=[(mask_num//(len(gens))**i)%len(gens) for i in range(l)]
                res=Permutation(n)
                for i in mask_inds: res*=gens[i]
                
                p=gen
                used={}
                power=1
                while(p.p not in used):
                    if checker(res*p):
                        # print('found',mask_inds,n,power,mask_num)
                        return (p,power,tuple(mask_inds))
                    used[p.p]=power
                    power+=1
                    p*=gen
                mask_num-=1
    return (None,None,None)

def good_swap(p):
    n=p.n
    sign=p.get_signature()
    if (sign[-1]!=2 or sign.count(1)!=n-2): return False
    for cycle in p.to_actual_cycles():
        if(len(cycle)==2 and cycle[0]%2==cycle[1]%2):
            return True
    return False
    
def find_cool_recipies(checker,max_rec,max_pref,s,f,step):
    ans={}
    for n in range(s,f,step):
        rn1=Prefix(n,n-2)
        rn=Prefix(n,n)
        r4=Prefix(n,4)
        gens=[r4,rn1,rn,rn*rn1,rn1*rn,rn*rn1*rn,rn*r4*rn]
        print("n is now",n)
        for rec_l in range(1,max_rec+1):
            print("rec_l is now", rec_l)
            mask_num=len(gens)**rec_l-1
            while(mask_num>=0):
                mask_inds=[(mask_num//(len(gens))**i)%len(gens) for i in range(rec_l)]
                res=Permutation(n)
                for i in mask_inds: res*=gens[i]
                # print(res.to_cycles())
                perm, power, pref = find_good_pref_powers(res,checker,gens,max_pref)
                if perm is not None:
                    k = tuple(mask_inds)
                    # print("found",pref,k,power)
                    if k not in ans:
                        ans[k]=[(n,power,pref)]
                    else:
                        ans[k].append((n,power,pref))
                mask_num-=1
    return ans

if __name__ == "__main__":
    d=find_cool_recipies(good_swap,6,3,7,13,1)
    # print(d)
    for i in d:
        if len(d[i])>=3:
            print(i,d[i])
    exit()
    goods=[]
    for n in range(6,13,2):
        # if n%4==1: continue
        # revs=[r4,rn1,rn,rn*rn1,rn1*rn,rn*rn1*rn,rn*r4*rn]
    #     A=compute(revs,"040304")

    #     A=A**(n-3)
    #     print(A.to_cycles())


    # recs=((3, 0, 1, 6, 1, 0), (3, 0, 4, 0, 3, 0), (0, 1, 6, 4, 6, 5), (5, 6, 3, 6, 1, 0), (5, 6, 5, 0, 3, 0), (0, 1, 6, 1, 0, 4), (0, 4, 0, 5, 6, 5), (0, 4, 0, 3, 0, 4))
    # for rec in recs:
    #     good_ns=[]
    #     for n in range(6,200):
    #         if n%4==1: continue
    #     # n=int(input())
    #     # r=input()
    #         # print("n =",n)
    #         rn1=Prefix(n,n-1)
    #         rn=Prefix(n,n)
    #         r4=Prefix(n,4)
    #         revs=[r4,rn1,rn,rn*rn1,rn1*rn,rn*rn1*rn,rn*r4*rn]
    #         names=['r4','rn1','rn','R','L','sn1','s4']
    #         good_ps=find_good_powers(compute(revs,''.join([str(i) for i in rec])),is_12)
    #         if len(good_ps)!=0:
    #             good_ns.append((n,good_ps[0][1]))
    #     print([names[i] for i in rec],good_ns)
        
        good=set()
        for i1 in range(len(revs)):
            for i2 in range(len(revs)):
                for i3 in range(len(revs)):
                    for i4 in range(len(revs)):
                        for i5 in range(len(revs)):
                            for i6 in range(len(revs)):
                                for i7 in range(len(revs)):
                                    for i8 in range(len(revs)):
                                        pows=find_good_powers(revs[i1]*revs[i2]*revs[i3]*revs[i4]*revs[i5]*revs[i6]*revs[i7]*revs[i8],is_13)
                                        if(len(pows)!=0):
                                            print(i1,i2,i3,i4,i5,i6,i7,i8,pows)
                                            good.add((i1,i2,i3,i4,i5,i6,i7,i8))
        goods.append(good)
    print(goods[-1].intersection(goods[-2]))

            # rec=q_find_smallest_good_product(revs,is_12)
        # if(':' in rec):
        #     print(":(")
        # else:
        #     print(' '.join([names[int(i)] for i in rec]))
    # print(compute(revs,r).to_cycles())
    # for n in range(9,40):
    #     # n=8
        # r="010202121210212012012012"
        # rn1=Prefix(n,n-1)
        # rn=Prefix(n,n)
        # r4=Prefix(n,4)
        # revs=[r4,rn1,rn]
        # ans=Permutation(n)
    #     for c in r: ans*=revs[int(c)]
    #     print(n,(ans).to_cycles())
    #     # exit(0)
    
'''
    for n in range(9,40):
        print("now n is ",n)
        rn1=Prefix(n,n-1)
        rn=Prefix(n,n)
        r4=Prefix(n,4)
        revs=[r4,rn1,rn]
        used={}
        nowp=revs[0]*revs[1]
        i=0
        while(nowp.p not in used):
            used[nowp.p]=0
            # nowp*=revs[0]
            if(nowp.get_signature().count(2)==1):
                print(nowp.to_cycles(),"01"+"01210"*i)
            # nowp*=revs[0]
            # if((nowp*revs[1]).get_signature().count(2)==1):
            #     print((nowp*revs[1]).to_cycles(),"01"+"21"*i+'1')
            i+=1
            nowp=nowp*revs[0]*revs[1]*revs[2]*revs[1]*revs[0]
        # print("0121",(revs[0]*revs[1]*revs[2]*revs[1]).to_cycles())
        # print("012121",(revs[0]*revs[1]*revs[2]*revs[1]*revs[2]*revs[1]).to_cycles())
        # print("01212121",(revs[0]*revs[1]*revs[2]*revs[1]*revs[2]*revs[1]*revs[2]*revs[1]).to_cycles())
        # print("0121212121",(revs[0]*revs[1]*revs[2]*revs[1]*revs[2]*revs[1]*revs[2]*revs[1]*revs[2]*revs[1]).to_cycles())
        
        # print("212",(revs[2]*revs[1]*revs[2]).to_cycles())
        # print(q_find_smallest_good_product(revs,is_1k_transposition))
        # print(q_find_smallest_good_product(revs,is_good_transposition))
        # print((rn1*rn).to_cycles())
'''