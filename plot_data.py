


plt.figure(figsize=(12, 6))
plt.plot(df['absorption_voltage'], label='Absorption Voltage', color='blue')
plt.plot(df['field_voltage'], label='Field Voltage', color='blue')


# Highlight the spikes on the plot
plt.scatter(spike_indices, df.loc[spike_indices, 'absorption_voltage'], color='red', label='Spikes', zorder=5)

# plt.scatter(spike_indices, df.loc[spike_indices, 'field_voltage'], color='red', label='Spikes', zorder=5)

# Adding title and labels
plt.title('Absorption Voltage and Detected Spikes')
plt.xlabel('Index')
plt.ylabel('Absorption Voltage')
plt.legend()

# Show the plot
plt.show()