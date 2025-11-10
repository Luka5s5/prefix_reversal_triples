with open('procres.txt','r') as f:
    d=0
    for i,line in enumerate(f):
        if d==1:
            d=0
            continue
        if 'Found' in line:
            d=1
            continue
        print(line.strip())

