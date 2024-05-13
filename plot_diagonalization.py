import sympy as sp
import numpy as np
import matplotlib.pyplot as plt

# Define variables
A, h, B, g, m = sp.symbols('A h B g m')

# Equations from Matrix 1
eq1 =  0.75 * A * h**2 + 0.5 * g * m * B
eq2 =  0.75 * A * h**2 - 0.5 * g * m * B
eq3 = -0.25 * A * h**2 - sp.sqrt(A**2 * h**4 + 0.5 * A * B * g * h**2 * m + 0.25 * B**2 * g**2 * m**2)
eq4 = -0.25 * A * h**2 + sp.sqrt(A**2 * h**4 + 0.5 * A * B * g * h**2 * m + 0.25 * B**2 * g**2 * m**2)
eq5 = -0.25 * A * h**2 - sp.sqrt(A**2 * h**4 + 0.25 * B**2 * g**2 * m**2)
eq6 = -0.25 * A * h**2 + sp.sqrt(A**2 * h**4 + 0.25 * B**2 * g**2 * m**2)
eq7 = -0.25 * A * h**2 - sp.sqrt(A**2 * h**4 - 0.5 * A * B * g * h**2 * m + 0.25 * B**2 * g**2 * m**2)
eq8 = -0.25 * A * h**2 + sp.sqrt(A**2 * h**4 - 0.5 * A * B * g * h**2 * m + 0.25 * B**2 * g**2 * m**2)

# Define the range for 'B' (or any variable)
b_values = np.linspace(0, 1, 400)

# Plot each equation
plt.figure(figsize=(10, 6))
for eq in [eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8]:
    # Lambda function to convert sympy expression to a numpy function
    f = sp.lambdify(B, eq.subs({A: 1, h: 1, g: 9.81, m: 1}), 'numpy')
    plt.plot(b_values, f(b_values), label=sp.pretty(eq))

plt.xlabel('B')
plt.ylabel('Value')
plt.title('Plot of Equations')
# plt.legend()
plt.grid(True)
plt.show()