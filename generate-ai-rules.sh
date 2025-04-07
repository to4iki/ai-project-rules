#!/usr/bin/env bash

# Generate rule files to be loaded by AI tools from rules-bank/

set -eo pipefail

RULES_BANK_DIR="rules-bank"
CLINERULES_DIR=".clinerules"
CLAUDE_FILE="CLAUDE.md"
COPILOT_FILE=".github/copilot-instructions.md"

generate_clinerules() {
  cp -r $RULES_BANK_DIR $CLINERULES_DIR
}

generate_claude() {
  # Generate root CLAUDE.md from rules-bank/*.md
  local first=true
  {
    find $RULES_BANK_DIR -maxdepth 1 -name "*.md" -type f | sort | while IFS= read -r file; do
      if [ "$first" = true ]; then
        cat "$file"
        first=false
      else
        printf "\n---\n\n"
        cat "$file"
      fi
    done
  } > $CLAUDE_FILE

  # Find all module directories and generate module-specific CLAUDE.md files
  find $RULES_BANK_DIR -mindepth 1 -maxdepth 1 -type d | sort | while IFS= read -r module_dir; do
    module_name=$(basename "$module_dir")
    module_claude_dir="${module_name}"

    local module_first=true
    {
      find "$module_dir" -maxdepth 1 -name "*.md" -type f | sort | while IFS= read -r file; do
        if [ "$module_first" = true ]; then
          cat "$file"
          module_first=false
        else
          printf "\n---\n\n"
          cat "$file"
        fi
      done
    } > "${module_claude_dir}/${CLAUDE_FILE}"
  done
}

# Concatenate files in rules-bank/ and generate copilot-instructions.md
generate_github_copilot_instructions() {
  local first=true
  {
    # Loop through the sorted list of .md files directly under rules-bank
    find $RULES_BANK_DIR -maxdepth 1 -name "*.md" -type f | sort | while IFS= read -r common_file; do
      base_filename=$(basename "$common_file")
      add_file_with_header "$common_file" $first false && first=false

      # Add files with the same name from each module directory if they exist
      find $RULES_BANK_DIR -mindepth 1 -maxdepth 1 -type d | sort | while IFS= read -r module_dir; do
        module_file="${module_dir}/${base_filename}"
        if [ -f "$module_file" ]; then
          add_file_with_header "$module_file" $first false && first=false
        fi
      done
    done
  } > $COPILOT_FILE
}

# Output file content with its filename
add_file_with_header() {
  local file_path=$1
  local first=$2
  local use_basename=${3:-false}
  local header

  if [ -f "$file_path" ]; then
    if [ "$use_basename" = true ]; then
      header=$(basename "$file_path")
    else
      header=$(get_relative_path "$file_path")
    fi

    if [ "$first" = true ]; then
      printf "%s\n\n" "$header"
    else
      printf "\n---\n%s\n\n" "$header"
    fi
    cat "$file_path"
    return 0
  fi
  return 1
}

# Convert the file path argument to a relative path from the current directory and output it
get_relative_path() {
  local full_path=$1
  echo "${full_path#$PWD/}"
}

if [ "$#" -eq 0 ]; then
  generate_clinerules
  generate_claude
  generate_github_copilot_instructions
else
  echo "Usage: $0"
  exit 1
fi
