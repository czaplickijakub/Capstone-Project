#Jakub Czaplicki
#My sample representation of the malware binary to grayscale image conversion technique for use on Microsoft BIG 2015 challenge. Draws from Nataraj et al. Unused during related paper experiments.
#5/2/24

#Import libraries
import numpy as np
import matplotlib.pyplot as plt
from math import ceil
import tkinter as tk
from tkinter import filedialog
import os

#As per Nataraj et al., define widths based on file size
def determine_width(file_size):
    if file_size < 10 * 1024:
        width = 32
    elif file_size < 30 * 1024:
        width = 64
    elif file_size < 60 * 1024:
        width = 128
    elif file_size < 100 * 1024:
        width = 256
    elif file_size < 200 * 1024:
        width = 384
    elif file_size < 500 * 1024:
        width = 512
    elif file_size < 1000 * 1024:
        width = 768
    else:
        width = 1024
    return width

#Generate images
def create_grayscale_image(file_path, output_dir):
    dpi = 500 #Increase DPI for higher resolution
    output_file_name = os.path.splitext(os.path.basename(file_path))[0] + f"_{dpi}dpi.png"
    output_file_path = os.path.join(output_dir, output_file_name)
    
    #Skip this file if it has already been processed
    if os.path.exists(output_file_path):
        print(f"{output_file_name} already exists. Skipping...")
        return
    
    #Read the binary file
    with open(file_path, 'rb') as file:
        binary_data = file.read()

    #Convert binary data to a vector of 8-bit unsigned integers
    data = np.frombuffer(binary_data, dtype=np.uint8)

    #Determine the width of the image based on file size
    width = determine_width(len(data))

    #Calculate the height, ensuring all bytes are included in the image
    height = ceil(len(data) / width)

    #Reshape the data into a 2D array (filling with zeros if necessary)
    image_data = np.zeros((height, width), dtype=np.uint8)  # Initialize with zeros
    image_data.flat[:len(data)] = data  # Fill with actual data
    
    #Determine the figure size based on image dimensions to maintain the aspect ratio
    fig_width, fig_height = plt.gcf().get_size_inches()
    desired_width = width / max(width, height) * fig_width
    desired_height = height / max(width, height) * fig_height

    #Visualize the data as a grayscale image
    fig, ax = plt.subplots(figsize=(width / 100, height / 100), dpi=dpi)  
    ax.imshow(image_data, cmap='gray', aspect='equal')  #Set aspect='equal' to avoid distortion
    plt.axis('off')  #Turn off axis numbers and ticks
    plt.subplots_adjust(top=1, bottom=0, right=1, left=0, hspace=0, wspace=0)  #Remove padding around the image
    
    #Save the image to the specified output directory
    plt.savefig(output_file_path, bbox_inches='tight', pad_inches=0)  # Remove any extra whitespace around the image
    plt.close()  #Close the plot to free up memory

#Setup the Tkinter root window but do not show it
root = tk.Tk()
root.withdraw()

#Ask the user to select an input directory
input_directory = filedialog.askdirectory(title='Select the input directory')

#Ask the user to select an output directory
output_directory = filedialog.askdirectory(title='Select the output directory')

# rocess all .bytes files in the selected input directory and its subdirectories
if input_directory and output_directory:
    for dirpath, dirnames, filenames in os.walk(input_directory):
        for filename in filenames:
            if filename.endswith('.bytes'):
                file_path = os.path.join(dirpath, filename)
                create_grayscale_image(file_path, output_directory)
                print(f"Created picture of {filename}")
else:
    print('No directory selected or invalid output directory.')
