# not a real python code, ignore weird syntax

import numpy as np

m = 1024
n = 2048

matrix = np.zeros((m, n), dtype=int)

def init(i, j):
    return i * n + j

for i in [0,... m - 1]:
    for j in [0,... n - 1]:
        matrix[i, j] = init(i, j)
