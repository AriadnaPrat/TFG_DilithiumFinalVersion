def NTT_prev(a, node, depth, list_):
    if depth == 1:
        list_.append(a[0])
        return None
    else:
        dd = depth // 2
        r=node.right
        r=R(r.residue)
        b = [0]*dd
        c = [0]*dd
        for i in range(dd):
            b[i] = (a[i] + r *a[i + dd])
            c[i] = (a[i] - r *a[i + dd])
            
        NTT_prev(b, node.left, dd, list_) 
        NTT_prev(c, node.right, dd, list_) 
        return None

def INTT_prev(ntt_list, node, depth):
    a=[0]*depth
    dd = depth//2
    r=node.right
    r_inv=R(r.residue)
    if depth==2:
        b, c = ntt_list
        a[0] = (b + c) / d
        a[1] = (r_inv * (b - c)) / d
        return PR(a)
    else:
        
        b = INTT_prev(ntt_list[:dd], node.left, dd) 
        c = INTT_prev(ntt_list[dd:], node.right, dd) 
        for i in range(dd):
            a[i] = (b[i] + c[i])
            a[i + dd] = (r_inv * (b[i] - c[i]))

        return PR(a)  
    
def NTT(poly):
    list_ = []
    NTT_prev(poly, tree.root, d, list_)
    return list_

def INTT(poly):
    result = INTT_prev(poly, tree_inv.root, d)
    return result