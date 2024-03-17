#!/bin/bash

# Usage check
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 \"commit message base\""
  exit 1
fi

COMMIT_MESSAGE_BASE="$1"

# Function to commit a batch of files
commit_files() {
  local batch_number="$1"
  local dir="$2"
  local files=("${@:3}") # Get all arguments starting from the third
  local task=$(basename "$dir")

  # Add files to staging
  git add "${files[@]}"
  
  # Commit with a specific message, including the batch number
  git commit -m "${COMMIT_MESSAGE_BASE} - ${task} (Batch ${batch_number})"
}

# Initialize an associative array to hold file paths grouped by their task directory
declare -A task_files

# Use git to list only changed files, excluding deletions
while IFS= read -r line; do
  # Extract the file path
  file=$(echo "$line" | awk '{print $2}')
  # Determine the task directory of the file
  task=$(dirname "$file")
  # Append the file to the array of files in its task directory
  task_files["$task"]+="$file "
done < <(git status -u --porcelain)

# Process each task's files in batches of up to 10
for task in "${!task_files[@]}"; do
  read -ra files <<<"${task_files[$task]}" # Convert space-separated string to array
  
  # Initialize an array to collect a batch of up to 10 files
  files_to_commit=()
  # Initialize a variable to keep track of the batch number for this task
  batch_number=0
  
  for file in "${files[@]}"; do
    files_to_commit+=("$file")
    
    # When we've collected 10 files, or are processing the last file in the task
    if [ "${#files_to_commit[@]}" -eq 15 ] || [[ "$file" == "${files[-1]}" ]]; then
      # Increment the batch number
      ((batch_number++))
      commit_files "$batch_number" "$task" "${files_to_commit[@]}"
      # Perform git push after each batch commit within the task
      git push
      files_to_commit=() # Reset the batch for the next iteration
    fi
  done
done

echo "All changes pushed successfully!"
