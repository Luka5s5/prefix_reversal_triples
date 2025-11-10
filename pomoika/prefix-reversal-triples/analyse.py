n,k = -1,-1
results = {}
with open('mach_res.txt','r') as f:
    for i,line in enumerate(f):
        line = line.strip().split()
        if i%2==0:
            n,k = (int(line[0]),int(line[1]))
            continue
        recipe = line[0]
        if recipe in results:
            results[recipe].append((n,k,n-k))
        else:
            results[recipe] = [(n,k,n-k)]

fil_rec = [recipe for recipe, res in results.items() if len(res)>=2]
fil_rec.sort(key = lambda x:len(x))

s = '{'+(','.join(['{'+(','.join(list(rec)))+'}' for rec in fil_rec]))+'}'

print(s)
