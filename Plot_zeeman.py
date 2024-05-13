import sympy as sp
import numpy as np
from sympy import S
from sympy.physics.quantum.cg import CG
import matplotlib.pyplot as plt


def get_F_states():
    F_min = abs(J - I)
    F_max = J + I
    F_values = range(int(F_min), int(F_max) + 1)

    fm_pairs = []
    for F in F_values:
        for M_F in range(-F, F + 1):
            fm_pairs.append((F, M_F))

    return fm_pairs

def get_IJ_states(F_state):
    # List to store the superposition components of f mf in this basis
    F, M_F = F_state
    superposition = []
    # scale by 2 for range
    M_I_values = range(int(-2*I), int(2*I + 1), 2)
    M_J_values = range(int(-2*J), int(2*J + 1), 2)
    
    for M_I in M_I_values:
        M_I = S(M_I) / 2  # scale by 1/2 to get to values
        for M_J in M_J_values:
            M_J = S(M_J) / 2
            if M_I + M_J == M_F:  # Clebsch-Gordan coefficients are non-zero only if M_F = M_I + M_J
                coeff = CG(I, M_I, J, M_J, F, M_F).doit()
                if coeff != 0:
                    superposition.append((coeff, M_I, M_J)) # assume I and J will be the constants
    return superposition

def op_hamiltonian(F_state1, F_state2):
    value = 0
    IJ_states1 = get_IJ_states(F_state1)
    IJ_states2 = get_IJ_states(F_state2)
    if F_state1 == F_state2:
        value += A * 0.5 * (F_state1[0] * (F_state1[0] + 1) - I * (I + 1) - J * (J + 1))
    for IJ_state1 in IJ_states1:
        for IJ_state2 in IJ_states2:
            # unpack states
            coef1, M_I1, M_J1 = IJ_state1
            coef2, M_I2, M_J2 = IJ_state2
            if M_J1 == M_J2 and M_I1 == M_I2:
                value += coef1 * coef2 * B * (g_j * M_J1 - g_i * M_I1)
    return value



def get_matrix(F_states):
    size = len(F_states)
    matrix = sp.zeros(size, size)
    for i in range(size):
        for j in range(size):
            matrix[i, j] = op_hamiltonian(F_states[i], F_states[j])
    return matrix

def plot_equations(equations, F_states):
    B_values = np.linspace(0, B_max, 400)
    for i, eq in enumerate(equations):
        func = sp.lambdify(B, eq.subs({A: A_value, g_j: g_j_value, g_i: g_i_value}), 'numpy')
        plt.plot(B_values, func(B_values), label=f'|{F_states[i][0]} {F_states[i][1]}>')
    plt.legend()
    plt.show()

def plot_gaps(equations, F_states):
    B_values = np.linspace(0, B_max, 400)
    plt.figure(figsize=(10, 6))
    # Compute differences between consecutive equations
    for i in range(len(equations) - 1):
        # verify the same hyperfine split
        if F_states[i][0] == F_states[i+1][0]:
            diff_eq = equations[i + 1] - equations[i]
            func = sp.lambdify(B, diff_eq.subs({A: A_value, g_j: g_j_value, g_i: g_i_value}), 'numpy')
            plt.plot(B_values, func(B_values), label=f'Diff between |{F_states[i+1][0]} {F_states[i+1][1]}> and |{F_states[i][0]} {F_states[i][1]}>')
    
    plt.title('Differences between Consecutive Energy Levels')
    plt.xlabel('Magnetic Field B')
    plt.ylabel('Energy Difference')
    plt.legend()
    plt.show()

I = 5/2
J = 1/2
A = sp.Symbol('A', real=True) # actually A hbar **2
g_j = sp.Symbol('g_j', real=True) # actually g_j mu_B
g_i = sp.Symbol('g_i', real=True) # actually g_i mu_N
B = sp.Symbol('B', real=True)  # external magnetic field

A_value = 1
g_j_value = 1
g_i_value = 0.01
B_max = 10

if __name__ == "__main__":
    F_states = get_F_states()
    # print(F_states)
    matrix = get_matrix(F_states)
    # sp.pprint(matrix)
    P, D = matrix.diagonalize() # D is the diagonalized matrix
    equations = [D[i, i] for i in range(D.shape[0])]
    # diagonalizing destroys order so sort to get back
    equations.sort(key=lambda x: x.subs({B: 0.01, A: A_value, g_j: g_j_value, g_i: g_i_value}).evalf())
    # print(equations)
    plot_equations(equations, F_states)
    plot_gaps(equations, F_states)

