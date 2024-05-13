import pandas as pd
import os
import matplotlib.pyplot as plt
import numpy as np

# Constants
freq = 60
data_dir = "High_Field_4_25_24"
csv_filename = "87Rb_HighField_T8.csv"
file_path = os.path.join(data_dir, csv_filename)

# Check if the file exists
if not os.path.exists(file_path):
    raise FileNotFoundError(f"File not found: {file_path}")

# Load the CSV file
data = pd.read_csv(file_path)

# Assign descriptive column names
data.columns = ["Time", "Field Voltage", "Absorption Voltage"]

# Define a function to convert voltage to magnetic field (Tesla)
def voltage_to_field(voltage):
    # Example conversion: 0.1 Tesla per Volt (replace with your calibration value)
    calibration_factor = 0.1  # Tesla per Volt
    return voltage * calibration_factor

# Convert Field Voltage to Magnetic Field
data['Magnetic Field (T)'] = data['Field Voltage'].apply(voltage_to_field)

# Plot the data
fig, ax = plt.subplots(figsize=(3.5, 3.5/1.618))
ax.plot(data['Time'], data['Magnetic Field (T)'], label='Magnetic Field (V)', color='blue')
ax.plot(data['Time'], data['Absorption Voltage'], label='Absorption Voltage', color='orange')
ax.set_xlabel("Time (s)")
ax.set_ylabel("Magnetic Field (T) / Voltage (V)")
# ax.set_title(f"{freq}kHz High Field Data from Optical Pumping Experiment")
plt.xlim(3660,3740)
#ax.legend()

# Function to handle mouse clicks on the plot
def onclick(event):
    # Display the x, y values of the click
    if event.xdata is not None and event.ydata is not None:
        time_clicked = event.xdata
        voltage_clicked = np.interp(time_clicked, data['Time'], data['Field Voltage'])
        magnetic_field = voltage_to_field(voltage_clicked)
        print(f"Clicked at Time: {time_clicked:.2f} s -> Field Voltage: {voltage_clicked:.2f} V -> Magnetic Field: {magnetic_field:.3f} T")

# Connect the onclick function to the mouse click event
cid = fig.canvas.mpl_connect('button_press_event', onclick)

# Ensure the figures directory exists
figures_dir = os.path.join(data_dir, "figures")
if not os.path.exists(figures_dir):
    os.makedirs(figures_dir)  # Create the directory if it doesn't exist

# Save the plot as an image with 300 dpi in the figures directory
output_filename = f"87Rb_kHz_high_field_data_plot.png"
output_path = os.path.join(figures_dir, output_filename)
plt.savefig(output_path, bbox_inches='tight', dpi=300)  # Save at 300 dpi

plt.show()
