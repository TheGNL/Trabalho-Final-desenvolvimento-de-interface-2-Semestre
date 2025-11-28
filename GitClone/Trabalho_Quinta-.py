import numpy as np

# Solicitando ao usuário as dimensões da matriz A
rows = int(input("Digite o número de linhas da matriz A: "))
cols = int(input("Digite o número de colunas da matriz A: "))

# Criando a matriz A com base nas dimensões fornecidas
A = np.zeros((rows, cols))
print("Digite os elementos da matriz A:")
for i in range(rows):
    for j in range(cols):
        A[i, j] = float(input(f"A[{i+1},{j+1}]: "))

# Criando o vetor b com base no número de linhas de A
b = np.zeros(rows)
print("\nDigite os elementos do vetor b:")
for i in range(rows):
    b[i] = float(input(f"b[{i+1}]: "))

print("Sistema a ser resolvido:")
print("Matriz A:\n", A)
print("\nVetor b:\n", b)
print("-" * 30)


# --- Método 1: Matriz Inversa ---
print("Resolvendo pelo Método da Matriz Inversa...")

x_inversa = None
try:
    # Calcula a inversa de A
    A_inv = np.linalg.inv(A)
    print("Inversa de A (A^{-1}):\n", A_inv)

    # Resolve x = A^{-1} * b
    # O operador @ em NumPy é usado para multiplicação de matrizes
    x_inversa = A_inv @ b
    print("\nSolução (x) encontrada:", x_inversa)

except np.linalg.LinAlgError:
    print("A matriz A não é inversível. O método da matriz inversa não pode ser aplicado.")

print("-" * 30)


# --- Método 2: Gauss-Jordan (usando a função otimizada do NumPy) ---
print("Resolvendo pelo Método de Gauss-Jordan (np.linalg.solve)...")
# A função np.linalg.solve() é a forma padrão e mais eficiente de resolver
# sistemas lineares em NumPy. Ela usa uma implementação baseada em
# eliminação gaussiana (decomposição LU), que é numericamente estável e rápida.

x_gauss = None
try:
    x_gauss = np.linalg.solve(A, b)
    print("\nSolução (x) encontrada:", x_gauss)

except np.linalg.LinAlgError:
    print("A matriz A é singular, o sistema pode não ter solução única.")

print("-" * 30)


# --- Interpretação dos Resultados ---
print("Interpretação:")
# np.allclose é usado para comparar arrays de ponto flutuante com uma tolerância
if x_inversa is not None and x_gauss is not None:
    if np.allclose(x_inversa, x_gauss):
        print("Ambos os métodos produziram o mesmo resultado.")
        solution_str = ", ".join([f"x{i+1} = {val}" for i, val in enumerate(x_gauss)])
        print(f"A solução para o sistema é {solution_str}.")
    else:
        print("Os métodos produziram resultados diferentes, o que indica um problema.")
elif x_gauss is not None:
    solution_str = ", ".join([f"x{i+1} = {val}" for i, val in enumerate(x_gauss)])
    print(f"A solução para o sistema (calculada com Gauss-Jordan) é {solution_str}.")
else:
    print("Não foi possível encontrar uma solução.")
