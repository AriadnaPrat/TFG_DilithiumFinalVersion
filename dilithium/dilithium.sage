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

        return self.A, self.t
        
    #Commitment
    def step1(self):
        self.y_1 = create_vector(gamma + beta_prima, m)
        self.y_2 = create_vector(gamma + beta_prima, n)

        y_1_ntt = NTT_vector(self.y_1)
        A_ntt = [NTT_vector(self.A[i]) for i in range(n)]
        y_1_A_ntt = multiply_vector_matrix(y_1_ntt, A_ntt, n, m)
        y_1_A_intt = INTT_vector(y_1_A_ntt)
        self.w = sum_vectors(y_1_A_intt, self.y_2, n)
        return self.w
    
    def step2(self, c):
        s1_ = NTT_vector(self.s1)
        s2_ = NTT_vector(self.s2)
        c_ntt = NTT(c)
        z_1_ = multiply_constant_vector(c_ntt, s1_)
        z_2_ = multiply_constant_vector(c_ntt, s2_)
        
        z_1 = sum_vectors(INTT_vector(z_1_),  self.y_1, m)
        z_2 = sum_vectors(INTT_vector(z_2_), self.y_2, n)
        if not is_in_range(z_1, beta_prima) or not is_in_range(z_2, beta_prima):
            return None, None
        else:
            return z_1, z_2

#Simulate the Verifier role
class Verifier:
    def __init__(self):
        self.c = None
    
    #Challenge
    def step1(self, A, t):
        self.c = generate_c() 
        shuffle(self.c)
        return Rk(self.c)
    
    def step2(self, z1, z2, w_, A, t):
        if is_in_range(z1, beta_prima) and is_in_range(z2, beta_prima):
            A_ntt = [NTT_vector(A[i]) for i in range(n)]
            z1_ntt = NTT_vector(z1)
            mult = multiply_vector_matrix(z1_ntt, A_ntt, n, m)
            mult_intt = INTT_vector(mult)
            sum_ = sum_vectors(mult_intt, z2, n)
            c_ntt = NTT(self.c)
            t_ntt = NTT_vector(t)
            const = multiply_constant_vector(c_ntt, t_ntt)
            const_intt = INTT_vector(const)
            cond = substract_vectors(sum_, const_intt, n) == w_
            if cond:
                return True
            else:
                return False
        else:
            return False

#We simulate the scheme Dilithium
v = Verifier()
p = Prover()

def simulate_protocol():
    A, t = p.keygen()
    w = p.step1()
    c = v.step1(A, t)
    z1, z2 = p.step2(c)
    #print(boolean)
    return z1, z2, w, A, t

while True:
    z1, z2, w, A, t = simulate_protocol()
    if z1 is None and z2 is None:
            continue
    else:
        boolean = v.step2(z1, z2, w, A, t)
        if boolean != False:
            print("Verification:", boolean)
            break

