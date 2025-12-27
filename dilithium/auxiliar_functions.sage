def multiply(a, b):
    list_ntt=[]
    for i in range(d):
        list_ntt.append(a[i]*b[i] % q)
    return list_ntt

def sample(eta):
    return random.randint(-eta, eta + 1) % q

def sample_uniform(eta):
    return Rk([sample(eta) for _ in range(d)])

def create_vector(eta, dimension):
    return [sample_uniform(eta) for _ in range(dimension)]

def sum_vectors(a, b, d1):
    return [a[i] + b[i] for i in range(d1)] 

def multiply_vector_matrix(v, M, d1, d2):
    resultado = []
    for j in range(d1): 
        suma = []
        for i in range(d2):  
            suma.append(multiply(v[i], M[j][i])) #v[i] * M[j, i]
        sum_ = [sum([suma[j][i] for j in range(m)]) for i in range(d)]
        resultado.append(sum_)
    return resultado

def generate_c():
    coef = [choice([-1, 1]) for _ in range(49)] + [0] * (d-49)

    shuffle(coef)
    
    return coef

def multiply_constant_vector(c, v):
    return [multiply(c,i) for i in v]

def create_matrix(d1, d2):
    return [[Rk([R(random.randint(0, q - 1)) for _ in range(d)]) for _ in range(d2)] for _ in range(d1)]

def NTT_vector(vector):
    return [NTT(i) for i in vector]

def INTT_vector(vector):
    return [INTT(i) for i in vector]

def is_in_range(v, beta_bar):
    for x in v:
        if not all((0 <= i.lift() <= beta_bar) or ((q - beta_bar) <= i.lift() <= (q - 1)) for i in x):
            return False

    return True 

def substract_vectors(a, b, d1):
    return [a[i] - b[i] for i in range(d1)] 

def HIGH_s(w, s):
    w_high = []
    for x in w:
        w_high.append(PR([ZZ(coef) // s for coef in x.list()]))
    return w_high

def LOW_s(w, s=16):
    w_low = []
    for x in w:
        w_low.append(PR([ZZ(coef) - (ZZ(coef)//s)*s for coef in x.list()]))
    return w_low