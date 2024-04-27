import pandas as pd
import os
import matplotlib.pyplot as plt

# Directory where the CSV file is stored
freq = 60
data_dir = "4_18_24-OP"
csv_filename = f"{freq}kHz_R1000_PT10_D15.csv"

# Construct the full path
file_path = os.path.join(data_dir, csv_filename)

# Check if the file exists
if not os.path.exists(file_path):
    raise FileNotFoundError(f"File not found: {file_path}")

# Load the CSV file
data = pd.read_csv(file_path)

# Assign descriptive column names
data.columns = ["Time", "Field Voltage", "Absorption Voltage"]

# Plot the data
plt.figure(figsize=(10, 6))
plt.plot(data["Time"], data["Field Voltage"], label="Field Voltage")
plt.plot(data["Time"], data["Absorption Voltage"], label="Absorption Voltage")
plt.xlabel("Time (s)")
plt.ylabel("Voltage (V)")
plt.title("Low Field Data from Optical Pumping Experiment")
plt.legend()

# Ensure the figures directory exists
figures_dir = os.path.join(data_dir, "figures")
if not os.path.exists(figures_dir):
    os.makedirs(figures_dir)  # Create the directory if it doesn't exist

# Save the plot as an image with 300 dpi in the figures directory
output_filename = f"{freq}kHz_low_field_data_plot.png"
output_path = os.path.join(figures_dir, output_filename)

plt.savefig(output_path, dpi=300)  # Save at 300 dpi

plt.show()
