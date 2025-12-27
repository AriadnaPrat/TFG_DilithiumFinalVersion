#DILITHIUM
import random
from random import choice, shuffle
import numpy as np

#Official Parameters Security Level 3
q =  2^23 - 2^13 + 1     
k = 4
d = 256       
n, m = 6, 5
beta = 4       
gamma = 49*4     
beta_prima = 2^19 - gamma - 1
R = IntegerModRing(q)  
PR.<X> = PolynomialRing(R)  
Rk = PR.quotient(X^d + 1)  
delta_s = (q - 1)/32 - 1
T = 2^13
s = 2^16

load("tree.sage")
load("NTT.sage")
load("auxiliar_functions.sage")
tree, r_list = build_tree(1, d)
tree_inv = build_inverse_tree_from(tree, q, 1)

#Simulate the Prover role
class Prover:
    def __init__(self):
        self.y_1 = None
        self.y_2 = None
        self.s1 = None
        self.s2 = None
        self.z1 = None
        self.z2 = None
        self.A = None
        self.t = None
        
    def keygen(self):
        self.s1 = create_vector(beta, m)
        self.s2 = create_vector(beta, n)
        self.A = create_matrix(n, m)
        A_ntt = [NTT_vector(self.A[i]) for i in range(n)]
        s1_ntt = NTT_vector(self.s1)
        t_ = multiply_vector_matrix(s1_ntt, A_ntt, n, m)
        self.t = sum_vectors(INTT_vector(t_), self.s2, n)
        self.y_A = None
        self.t_1 = HIGH_s(self.t, T)

        return self.A, self.t
        
    #Commitment
    def step1(self):
        self.y = create_vector(gamma + beta_prima, m)

        y_ntt = NTT_vector(self.y)
        A_ntt = [NTT_vector(self.A[i]) for i in range(n)]
        y_A_ntt = multiply_vector_matrix(y_ntt, A_ntt, n, m)
        y_A_intt = INTT_vector(y_A_ntt)

        self.y_A = y_A_intt

        self.w = HIGH_s(self.y_A, s)
        
        return self.w
    
    def step2(self, c):
        s1_ = NTT_vector(self.s1)
        s2_ = NTT_vector(self.s2)
        c_ntt = NTT(c)
        z_= multiply_constant_vector(c_ntt, s1_)
        z_1 = INTT_vector(z_)
        
        z = sum_vectors(z_1,  self.y, m)
        c_s2_ntt= multiply_constant_vector(c_ntt, s2_)
        c_s2_intt = INTT_vector(c_s2_ntt)
        low_content = substract_vectors(self.y_A, c_s2_intt, n)
        low_cond = LOW_s(low_content)

        if not is_in_range(z, beta_prima) or not is_in_range(low_cond, delta_s - gamma):
            return None, None
        else:
            t_0 = LOW_s(self.t, T)
            t0_c = multiply_constant_vector(c_ntt, NTT_vector(t_0))
            t0_c_intt = INTT_vector(t0_c)
            if not is_in_range(t0_c_intt, delta_s):
                return None, None
            A_z = multiply_vector_matrix(NTT_vector(z), [NTT_vector(self.A[i]) for i in range(n)], n, m)
            A_z_intt = INTT_vector(A_z)
            c_t_1_ntt = multiply_constant_vector(c_ntt, NTT_vector(self.t_1))
            c_t_1_intt = INTT_vector(c_t_1_ntt)
            AZ_ct = substract_vectors(A_z_intt, c_t_1_intt, n)
            return z, HINT(AZ_ct, t0_c_intt)

#Simulate the Verifier role
class Verifier:
    def __init__(self):
        self.c = None
    
    #Challenge
    def step1(self, A, t):
        self.c = generate_c() 
        shuffle(self.c)
        return Rk(self.c)
    
    def step2(self, z, w_, A, t):
        A_z_ntt = multiply_vector_matrix(NTT_vector(z), [NTT_vector(A[i]) for i in range(n)], n, m)
        A_z_intt = INTT_vector(A_z_ntt)
        c_t_ntt = multiply_constant_vector(NTT(self.c), NTT_vector(t))
        c_t_intt = INTT_vector(c_t_ntt)
        w_result = substract_vectors(A_z_intt, c_t_intt, n)
        w_high = HIGH_s(w_result, s)
        if is_in_range(z, beta_prima) and w_high == w_:
            return True
        else:
            return False

#We simulate the scheme Dilithium
v = Verifier()
p = Prover()

def HINT(f1, f2):
    high_f1 = HIGH_s(f1, s)
    print(high_f1[0][255])
    high_f2 = HIGH_s(f2, s)
    print(high_f2[0][255])
    hint = []
    for i in range(n):
        for j in range(d):
            if high_f1[i][j] != high_f2[i][j]:
                hint.append(1)
            else:
                hint.append(0)
    return hint
    

def simulate_protocol():
    A, t = p.keygen()
    w = p.step1()
    c = v.step1(A, t)
    z, h = p.step2(c)
    return  z, w, A, t

while True:
    z, w, A, t = simulate_protocol()
    print("ss")

    if z is None:
            continue
    else:
        boolean = v.step2(z, w, A, t)
        if boolean != False:
            print("Verification:", boolean)
            break
