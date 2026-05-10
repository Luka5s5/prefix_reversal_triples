#!/usr/bin/env python3

while s := input():
    if s[0] in ('T', 'F'):
        continue
    print(s.split()[2])
