import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat

type = 'M_W'
file_path = r'gpt_api_task\results\M_W\gpt4o_topP05.txt'

# Plot with or without human data
human = True


def parse_data(filename):
    # Read the entire file content
    with open(filename, 'r') as file:
        file_content = file.read()

    # Split the content by lines
    lines = file_content.split('\n')

    # Initialize an empty dictionary
    data = {}

    # Iterate over each line to extract field names and values
    for line in lines:
        line = line.strip()
        if line:
            # Extract the field name and values
            field, values_str = line.split(':', 1)
            values_str = values_str.strip()

            # Remove square brackets and split the values by commas
            values_str = values_str[1:-1]  # Remove '[' and ']'
            values = [
                value.strip().replace("'", "") for value
                in values_str.split(',')]

            # Store the values in the dictionary
            data[field.strip()] = values
    print(data)

    return data


# Main script
data = parse_data(file_path)

# Rotation angles
angles = [0, 45, 90, 135, 180, 225, 270, 315]

if type == 'left_right':
    first_field = 'left_cube'
    first_response = 'LEFT'
    second_field = 'right_cube'
    second_response = 'RIGHT'
    plotlabel1 = 'left'
    plotlabel2 = 'right'
elif type == 'infront_behind':
    first_field = 'cube_front'
    first_response = 'INFRONT'
    second_field = 'sphere_front'
    second_response = 'BEHIND'
    plotlabel1 = 'infront'
    plotlabel2 = 'behind'
elif type == '9_6':
    first_field, first_response, plotlabel1 = ['6'] * 3
    second_field, second_response, plotlabel2 = ['9'] * 3
elif type == 'M_W':
    first_field, first_response, plotlabel1 = ['M'] * 3
    second_field, second_response, plotlabel2 = ['W'] * 3

# Initialize correct proportions
first_correct = np.zeros(len(angles))
second_correct = np.zeros(len(angles))

# Parse data and calculate correct proportions
for i, angle in enumerate(angles):
    print(first_field)
    print(f'Angle: {angle}')
    first_field_data = f'{first_field}_{angle}'
    second_field_data = f'{second_field}_{angle}'

    # Extract the lists of responses
    first_data = data[first_field_data]
    second_data = data[second_field_data]

    # Calculate the proportions of correct responses
    first_correct[i] = sum(
        [1 for response in first_data if
         response == first_response]) / len(first_data)
    second_correct[i] = sum(
        [1 for response in second_data if
         response == second_response]) / len(second_data)

# Plot
fig, ax1 = plt.subplots(figsize=(8, 6))

# Plot the first two lines on ax1
ax1.plot(angles, first_correct * 100, 'b-o', linewidth=2.5,
         label=f'Cube: {plotlabel1}')
ax1.plot(angles, second_correct * 100, 'r-o', linewidth=2.5,
         label=f'Cube: {plotlabel2}')
ax1.set_ylabel('Correct (%)', fontsize=14)
ax1.set_xlabel('Rotation (°)', fontsize=14)
ax1.tick_params(axis='both', which='major', labelsize=12)

# If `human` is True, create a second y-axis and plot the human reaction time
if human:
    ax2 = ax1.twinx()
    if type == 'left_right':
        data = loadmat('human_task/data/group/leftright.mat')
        data = data['left_right']
        human_rt = data[0]
        print(human_rt)
        human_error = data[1]
    elif type == '9_6':
        data = loadmat('human_task/data/group/ninesix.mat')
        data = data['nine_six']
        human_rt = data[0]
        human_error = data[1]
    elif type == 'M_W':
        data = loadmat('human_task/data/group/MW.mat')
        data = data['M_W']
        human_rt = data[0]
        human_error = data[1]
    # Add error bars to the human reaction time
    ax2.errorbar(angles, human_rt, yerr=human_error, fmt='g-s', linewidth=2.5,
                 label='Human RT', alpha=0.5)
    ax2.set_ylabel('Reaction Time (s)', fontsize=14)
    ax2.tick_params(axis='both', which='major', labelsize=12)


# Create a combined legend and place it below the title
lines_labels = [ax.get_legend_handles_labels() for ax in fig.axes]
lines, labels = [sum(lol, []) for lol in zip(*lines_labels)]
fig.legend(lines, labels, loc='upper center', bbox_to_anchor=(0.5, 0.9),
           ncol=3, fontsize=12)

# Rotate x-ticks based on the angles
ax1.set_xticks(angles)
ax1.set_xticklabels(angles, fontsize=12)

# Adjust layout to prevent overlap
fig.tight_layout(rect=[0, 0, 1, 0.85])

# Show the plot
plt.show()
