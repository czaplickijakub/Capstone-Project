#!/bin/bash

#Jakub Czaplicki
#Code to batch the IQA process across multiple defined algorithms. 
#5/2/24
#NOTE: Code relies on modified version of inference_iqa.py from IQA-PyTorch

#Define path to image folder
IMAGE_DIRECTORY="[INSERT PATH]"
#Defnine save path folder
SAVE_FILE_PREFIX="[INSERT PATH]"

#Path to .txt file of models, seperated by newline
ALGORITHM_FILE="[INSERT PATH]"

#Path to Py-IQA engine
SCRIPT_PATH="[INSERT PATH]"
#Sample tmp file path
TEMP_FILE="/tmp/output_temp.txt"

#If not present, make save file folder
mkdir -p "$SAVE_FILE_PREFIX"

#Read each line from the algorithm file
while IFS= read -r model
do
    #Check if the line is empty
    if [ -z "$model" ]; then
        continue
    fi

    #Define the save file with the model name appended
    save_file="${SAVE_FILE_PREFIX}_${model}.txt"

    #Run the Python script with the current model and capture the terminal output
    python3 -u "$SCRIPT_PATH" --metric_mode=NR -m "$model" -i "$IMAGE_DIRECTORY" --save_file "$save_file" 2>&1 | tee "$TEMP_FILE"

    #Extract the average score and append it to the save file
    average_score=$(grep -i "Average $model score" "$TEMP_FILE")
    echo "$average_score" >> "$save_file"

    echo "Processed model $model, average score: $average_score, output saved to $save_file"
done < "$ALGORITHM_FILE"

#Clean up temporary file
if [ -f "$TEMP_FILE" ]; then
    rm "$TEMP_FILE"
else
    echo "No temporary file to remove."
fi