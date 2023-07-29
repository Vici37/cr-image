#!/usr/bin/python3

print("This is a reference implementation of the fast fourier transform and comparing it to numpy")

import numpy as np
import time

#Cribbed from: https://towardsdatascience.com/fast-fourier-transform-937926e591cb
def fft_v(x):
    x = np.asarray(x, dtype=float)
    N = x.shape[0]

    N_min = min(N, 1)

    n = np.arange(N_min)
    k = n[:, None]
    M = np.exp(-2j * np.pi * n * k / N_min)
    # print(M)
    X = np.dot(M, x.reshape((N_min, -1)))
    # print(X)
    # print(X.shape)
    start = time.monotonic()
    while X.shape[0] < N:
        # print("-------")
        print("%f: start" % (time.monotonic() - start))
        print("\t%f: even and odds" % (time.monotonic() - start))
        X_even = X[:, :int(X.shape[1] / 2)]
        X_odd = X[:, int(X.shape[1] / 2):]
        print("\t%f: even and odds done, now terms" % (time.monotonic() - start))
        # print("Xeven", X_even)
        # print("Xodd", X_odd)
        # print("Xshape", X.shape[0])
        terms = np.exp(-1j * np.pi * np.arange(X.shape[0])
                        / X.shape[0])[:, None]
        print("\t%f: terms done, now new ret" % (time.monotonic() - start))
        # print("terms0", terms)
        # print(terms)
        X = np.vstack([X_even + terms * X_odd, X_even - terms * X_odd])
        print("\t%f: new ret done" % (time.monotonic() - start))
        # print(X)
    # print("--- done ---")
    # print(X)

    return X.ravel()

arr = np.array([1, 2, 3, 4, 7, 6, 9, 2])

print(fft_v(arr))
print(np.fft.fft(arr))


# r = np.random.random(1024)

# t = time.monotonic()
# fft_v(r)
# print("Time:", time.monotonic() - t)

# with open('in.txt', 'w') as f:
    # [f.write("%f," % n) for n in r]

# Sample output of the above (using different print statements than currently here)
# M: [[1.+0.j]]
# X: [[1.+0.j 2.+0.j 3.+0.j 4.+0.j 7.+0.j 6.+0.j 9.+0.j 2.+0.j]]
# X.shape: (1, 8)
# -------
# Xeven [[1.+0.j 2.+0.j 3.+0.j 4.+0.j]] 0, 1, 2, 3
# Xodd [[7.+0.j 6.+0.j 9.+0.j 2.+0.j]] 4, 5, 6, 7
# Xshape 1
# half 4
# terms [[1.+0.j]]
#  0 + 4     1 + 5  2 + 6    3 + 7      0 - 4   1 - 5  2 - 6    3 - 7
# [[ 8.+0.j  8.+0.j 12.+0.j  6.+0.j], [-6.+0.j -4.+0.j -6.+0.j  2.+0.j]]
# -------
# Xeven [[ 8.+0.j  8.+0.j], [-6.+0.j -4.+0.j]] 0, 1, 4, 5
# Xodd [[12.+0.j  6.+0.j], [-6.+0.j  2.+0.j]] 2, 3, 6, 7
# Xshape 2
# half 2
# terms [[1.000000e+00+0.j], [6.123234e-17-1.j]]
#  0 + 2      1 + 3    4 + 6t1 5 + 7t1    0 - 2    1 - 3     4 - 6t1 5 - 7t1
# [[20.+0.j 14.+0.j],[-6.+6.j -4.-2.j], [-4.+0.j  2.+0.j], [-6.-6.j -4.+2.j]]
# -------
# Xeven [[20.+0.j],[-6.+6.j], [-4.+0.j], [-6.-6.j]] 0, 2, 4, 6
# Xodd [[14.+0.j],[-4.-2.j], [ 2.+0.j], [-4.+2.j]] 1, 3, 5, 7
# Xshape 4
# half 1
# terms [[ 1.00000000e+00+0.j],[ 7.07106781e-01-0.70710678j], [ 6.12323400e-17-1.j], [-7.07106781e-01-0.70710678j]]
#    0 + 1       2 + 3t1                    4 + 5t2        6 + 7t3                   0 - 1       2 - 3t1                   4 - 5t2       6 - 7t3
# [[ 34.+0.j],[-10.24264069+7.41421356j], [ -4.-2.j], [ -1.75735931-4.58578644j], [  6.+0.j], [ -1.75735931+4.58578644j], [ -4.+2.j], [-10.24264069-7.41421356j]]
# --- done ---
# [[ 34.+0.j        ]
#  [-10.24264069+7.41421356j][ -4.        -2.j        ]
#  [ -1.75735931-4.58578644j]
#  [  6.        +0.j        ]
#  [ -1.75735931+4.58578644j]
#  [ -4.        +2.j        ]
#  [-10.24264069-7.41421356j]]
# [ 34.        +0.j         -10.24264069+7.41421356j
# -4.        -2.j          -1.75735931-4.58578644j
#    6.        +0.j          -1.75735931+4.58578644j
#   -4.        +2.j         -10.24264069-7.41421356j]
# [ 34.        +0.j         -10.24264069+7.41421356j
# -4.        -2.j          -1.75735931-4.58578644j
#    6.        +0.j          -1.75735931+4.58578644j
#   -4.        +2.j         -10.24264069-7.41421356j]
