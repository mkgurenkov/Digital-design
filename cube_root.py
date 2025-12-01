import math
import numpy

def cube_alg(x):
    return math.floor(numpy.cbrt(x))

def cube_hw(x):
    y = 0
    for s in range(6, -3, -3): # from = 6 works if x is 1byte
        y = 2*y
        b = (3*y*(y + 1) + 1) << s
        print("b " + str(b))
        print("y " + str(y))
        if (x >= b):
            x = x - b
            y = y + 1
    return y

# Test
# for x in range(0, 10, 1):
#     a = pow(x, 3)
#     alg_val = cube_alg(a)
#     hw_val = cube_hw(a)
#     if (alg_val == hw_val):
#         print("Correct! x: ", str(a).ljust(6), "; y: ", str(hw_val).ljust(6))
#     else:
#         print("ERROR! x: ", str(a).ljust(6), "; y(model): ", str(alg_val).ljust(6), "; y(hw): ", hex(hw_val).ljust(6))

print(cube_hw(64))

# b 64
# b 8
# b 19
# Correct! x:  27     ; y:  3    