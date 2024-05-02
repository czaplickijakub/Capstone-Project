#!/bin/bash

#Jakub Czaplicki
#Code to batch the IQA process across multiple defined algorithms and additionally multiple directories. 
#5/2/24
#NOTE: Code relies on modified version of inference_iqa.py from IQA-PyTorch

#Base save file path
BASE_SAVE_PATH="[INSERT PATH]"
#Path to .txt file with algorithms to use, seperated by newline
ALGORITHM_FILE="[INSERT PATH]"
#Path to Py-IQA engine
SCRIPT_PATH="[INSERT PATH]"
#Sample tmp file path
TEMP_FILE="/tmp/output_temp.txt"

#Define the array of image directories to process
IMAGE_DIRECTORIES=(
"[INSERT PATHS]"
)

#Loop over each image directory
for IMAGE_DIRECTORY in "${IMAGE_DIRECTORIES[@]}"; do
    echo "Processing directory: $IMAGE_DIRECTORY"

    #Create save path based on directory structure
    SAVE_DIRECTORY="${BASE_SAVE_PATH}$(echo "$IMAGE_DIRECTORY" | cut -d'/' -f6-)"
    #If not present, make directory
    mkdir -p "$SAVE_DIRECTORY"

    #Read each line from the algorithm file
    while IFS= read -r model; do
        #Check if the line is empty
        if [ -z "$model" ]; then
            continue
        fi

        #Define the save file with the model name and directory name appended
        save_file="${SAVE_DIRECTORY}/${model}.txt"

        #Run the Python script with the current model and capture the terminal output
        python3 -u "$SCRIPT_PATH" --metric_mode=NR -m "$model" -i "$IMAGE_DIRECTORY" --save_file "$save_file" 2>&1 | tee "$TEMP_FILE"

        #Extract the average score and append it to the save file
        average_score=$(grep -i "Average $model score" "$TEMP_FILE")
        echo "$average_score" >> "$save_file"

        echo "Processed model $model, average score: $average_score, output saved to $save_file"
    done < "$ALGORITHM_FILE"
done

#Clean up temporary file
if [ -f "$TEMP_FILE" ]; then
    rm "$TEMP_FILE"
else
    echo "No temporary file to remove."
fi
