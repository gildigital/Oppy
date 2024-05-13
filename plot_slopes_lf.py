import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sqlalchemy import false
import os

directory = '4_18_24-OP/'

# List to store results for each file
all_results = {}

# Loop through each file in the directory
for filename in os.listdir(directory):
    filepath = os.path.join(directory, filename)
        
    df = pd.read_csv(filepath, header=None)
    # Load the CSV file

    df.columns = ['time', 'field_voltage', 'absorption_voltage']

    df['voltage_difference'] = df['absorption_voltage'].diff()

    spike_indices = []
    found = False
    spikes = []

    for j in range(1, len(df)):
        if df.loc[j, 'absorption_voltage'] < -4:
            if df.loc[j, 'voltage_difference'] > 0 and not found:
                # The point just before this positive change is the spike
                spikes.append((j-1, df.loc[j - 1, 'absorption_voltage'], df.loc[j - 1, 'field_voltage']))
                found = True
        try:
            if df.loc[j, 'absorption_voltage'] - df.loc[j+50, 'absorption_voltage'] > 0:
                found = False
        except:
            pass


    if spikes:
        min_spike = min(spikes, key=lambda x: x[1])
        min_index = spikes.index(min_spike)

        # Determine the index range for the two spikes before and after the minimum spike
        start = max(0, min_index - 2)
        end = min(len(spikes), min_index)
        
        # Extract the required spike data
        relevant_spikes = spikes[start:end]

        # Calculate adjusted absorption voltages based on the central spike's absorption voltage
        central_absorption_voltage = min_spike[2]
        voltage_difs = [spike[2] - central_absorption_voltage for spike in relevant_spikes]
        b_difs = [voltage*8.991*10**-3*11/0.1639 for voltage in voltage_difs]
        # Store results using the numeric prefix
        numeric_prefix = filename.split('k')[0]  # Splits and takes the part before the first '4'
        numeric_prefix = int(numeric_prefix) 
        all_results[numeric_prefix] = b_difs

print(all_results)
# Prepare data for plotting
x = []  # Numeric prefixes
y = []  # b values
slopes = []  # Slopes between successive spikes
colors = ['red', 'green', 'blue', 'orange', 'purple']  # colors for spikes 1-5

# Populate x, y for scatter plot and slopes
for numeric_prefix, b_vals in all_results.items():
    for i, b_val in enumerate(b_vals):
        x.append(numeric_prefix)
        y.append(b_val)
        if i > 0:  # Calculate slope if not the first spike
            slope = (b_vals[i] - b_vals[i-1]) / 1  # Assuming uniform distance of 1 between spikes
            slopes.append((numeric_prefix, slope))

# Create the first scatter plot for b values
plt.figure(figsize=(3.5, 3.5/1.618))
# plt.subplot(2, 1, 1)
for i in range(2):
    # plot each spike's b values separately to maintain distinct colors
    y_vals =  [num_prefix for j, num_prefix in enumerate(x) if j % 2 == i]
    x_vals = [-b for j, b in enumerate(y) if j % 2 == i]
    plt.scatter(x_vals, y_vals, color=colors[i], label=f'Spike #{i+1}')
    if x_vals and y_vals:  # Ensure there are points to fit
        coeffs = np.polyfit(x_vals, y_vals, 1)
        poly = np.poly1d(coeffs)
        plt.plot(x_vals, poly(x_vals), linestyle='--', label=f'Fit for Spike #{i+1}: y = {coeffs[0]:.3e}x + {coeffs[1]:.3e}')
    print(coeffs[0])


plt.xlim(0)
plt.ylim(0)
plt.xlabel('Magnetic Field Strength (gauss)')
plt.ylabel('Frequency (KHz)')
#plt.legend()

plt.savefig(directory + "Slopes_freq_vs_B.png", bbox_inches='tight', dpi=300)

plt.show()