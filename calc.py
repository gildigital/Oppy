import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sqlalchemy import false
import os
import pickle # serialize and deserialize Python objects to and from a file 

directory = '4_18_24-OP/'

# File to save results
results_file = 'all_results.pkl'

# Check if results file exists
if os.path.exists(results_file):
    # Ask if calculations should be redone
    redo_calculations = input("Results file exists. Do you want to redo the calculations and overwrite? (y/n): ").strip().lower()

    if redo_calculations == 'y':
        calculate = True
    elif redo_calculations == 'n':
        calculate = False
    else:
        print("Invalid input. Exiting...")
        calculate = False
else:
    calculate = True

if calculate:
    # List to store results for each file
    all_results = {}

    # Loop through each file in the directory
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        
        df = pd.read_csv(filepath, header=None)
        # Load the CSV file

        df.columns = ['time', 'field_voltage', 'absorption_voltage']

        # Calculate the differences between consecutive absorption_voltage readings
        df['voltage_difference'] = df['absorption_voltage'].diff()

        # We want to find significant negative changes, indicating downward spikes
        # You might need to adjust the threshold according to your specific data characteristics
        spike_indices = []

        # Loop through the DataFrame to find sequences that meet the criteria
        found = False
        spikes = []

        for j in range(1, len(df)):
            if df.loc[j, 'absorption_voltage'] < -4:
                if df.loc[j, 'voltage_difference'] > 0 and not found:
                    # The point just before this positive change is the spike
                    spikes.append((j-1, df.loc[j - 1, 'absorption_voltage'], df.loc[j - 1, 'field_voltage']))
                    # spike_indices.append(j - 1)
                    # field_voltages_at_spikes.append(df.loc[j - 1, 'field_voltage'])
                    found = True
            try:
                if df.loc[j, 'absorption_voltage'] - df.loc[j+50, 'absorption_voltage'] > 0:
                    found = False
            except:
                pass

        print(spikes)

        # Convert to a NumPy array for possible further operations

        if spikes:
            min_spike = min(spikes, key=lambda x: x[1])
            min_index = spikes.index(min_spike)

            # Determine the index range for the two spikes before and after the minimum spike
            start = max(0, min_index - 2)
            end = min(len(spikes), min_index + 3)
        
            # Extract the required spike data
            relevant_spikes = spikes[start:end]

            # Calculate adjusted absorption voltages based on the central spike's absorption voltage
            central_absorption_voltage = min_spike[2]
            voltage_difs = [spike[2] - central_absorption_voltage for spike in relevant_spikes]
            b_difs = [voltage*8.991*10**-3*11/0.1639 for voltage in voltage_difs]

            # Improved extraction of numeric prefixes from filenames
            # Assuming the prefix is the number before the first 'k' in the filename
            numeric_prefix = ''.join(filter(str.isdigit, filename.split('k')[0]))  # Get only digits
            if numeric_prefix.isdigit():
                numeric_prefix = int(numeric_prefix)
            else:
                raise ValueError(f"Invalid filename format: {filename}")
            all_results[numeric_prefix] = b_difs

    # Save the results to a file using pickle
    with open(results_file, 'wb') as f:
        pickle.dump(all_results, f)
else:
    # Load the existing results from the file
    with open(results_file, 'rb') as f:
        all_results = pickle.load(f)

print(all_results)

# Prepare data for plotting
slopes = []  # Slopes between successive spikes
colors = ['red', 'green', 'blue', 'orange', 'purple']  # colors for spikes 1-5
x = []  # Numeric prefixes
y = []  # B values

# Populate x and y from all_results
for numeric_prefix, b_vals in all_results.items():
    for b_val in b_vals:
        x.append(numeric_prefix)
        y.append(b_val)

# Ensure x and y have data before sorting
if not x or not y:
    raise ValueError("No data available to plot. Check calculations or source data.")

# Sort x and y based on x
sorted_data = sorted(zip(x, y))  # Pair x and y and sort

# Ensure sorted_data is not empty before unpacking
if not sorted_data:
    raise ValueError("No sorted data available. Check data source or calculation logic.")

# Unpack sorted pairs
x_sorted, y_sorted = zip(*sorted_data)

# Create the scatter plot
plt.figure(figsize=(12, 12))
for i in range(5):
    # Ensure sufficient data before attempting to use modulus operation
    if len(x_sorted) < 5 or len(y_sorted) < 5:
        raise ValueError("Insufficient data to plot. Ensure proper data processing.")

    # Separate elements based on index modulus after sorting
    x_values = [x_sorted[j] for j in range(len(x_sorted)) if j % 5 == i]
    y_values = [y_sorted[j] for j in range(len(y_sorted)) if j % 5 == i]

    # Debugging print statements
    print(f"Spike {i + 1}: x = {x_values}, y = {y_values}")

    # Plotting with separated values
    plt.scatter(x_values[0], y_values[0], color=colors[i], label=f'Spike {i + 1}')

plt.title('Value of B for Spikes 1-5 vs Frequency (kHz)')
plt.xlabel('Frequency (kHz)')
plt.ylabel('B value')
plt.legend()
plt.show()