m = "QEPKSUS"
c = "BACCACA"
nm = ""
for i in range(len(m)):
    n = ord(m[i]) - (ord(c[i]) - ord("A"))
    n = (n-ord("A")) % 26
    n += ord("A")
    nm += chr(n)

print(nm)