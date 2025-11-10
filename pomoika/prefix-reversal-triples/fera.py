f = True
while f:
    s=""
    try:
        s=input()
    except:
        break
    print(s.replace(' ','.'))
