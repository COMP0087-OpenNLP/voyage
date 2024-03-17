#!/bin/bash

# Check if a commit message base was provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 \"commit message base\""
  exit 1
fi

# Base commit message
COMMIT_MESSAGE_BASE="$1"

# Get a list of all changed files
FILES=$(git status -u --porcelain | awk '{print $2}')

# Loop through each file and commit and push individually
for FILE in $FILES; do
  # Add the specific file
  git add "$FILE"

  # Commit the change with a specific message
  COMMIT_MESSAGE="$COMMIT_MESSAGE_BASE - $FILE"
  git commit -m "$COMMIT_MESSAGE"

  # Push the commit to the remote repository
  # Replace 'main' with your branch name if different
  git push
done

echo "All changes pushed successfully!"