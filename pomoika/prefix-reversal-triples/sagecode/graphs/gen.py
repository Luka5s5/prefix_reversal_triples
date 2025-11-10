import ast
import os
from collections import defaultdict

import matplotlib.pyplot as plt
import numpy as np

# Read and parse the data file
data = []
file_path = 'nohup.out'

with open(file_path, 'r') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = ast.literal_eval(line)
            if isinstance(entry, tuple) and len(entry) == 4:
                a, b, n, I = entry
                if a < b and n >= 2:
                    data.append((a, b, n, I))
                if (not (a+1==b or b+1==n or b+2==n)) and I==1:
                    print(line)


        except Exception as e:
            print(f"Skipping line due to error: {line} | Error: {e}")
