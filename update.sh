#!/bin/bash

# Get dokuwiki filename from input
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <filename.dokuwiki>"
    exit 1
fi

# Check if file exists
if [[ ! -f "$1" ]]; then
    echo "File '$1' does not exist."
    exit 1
fi

# Check if file is a DokuWiki file
if [[ ! "$1" =~ \.dokuwiki$ ]]; then
    echo "File '$1' is not a DokuWiki file."
    exit 1
fi

# Check if the file is .out 
if [[ "$1" =~ \.out$ ]]; then
    echo "File '$1' is already an output file."
    exit 1
fi

# Set variables
dokuwiki_file="$1"
ini_file="${dokuwiki_file%.dokuwiki}.ini"
output_file="${dokuwiki_file%.dokuwiki}.out"

# Create a copy of the DokuWiki file to modify
cp "$dokuwiki_file" "$output_file"

# Function to parse the INI file and apply changes
parse_ini() {
    local ini_file=$1
    local output_file=$2

    # Extract key-value pairs, ignoring section headers and empty lines
    grep -v '^\[' "$ini_file" | while IFS='=' read -r key value; do
        # Trim leading and trailing spaces from key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # in value replace %% with %
        value=$(echo "$value" | sed 's/%%/%/g')

        # Skip empty lines or lines with only whitespace
        if [[ -z "$key" || -z "$value" ]]; then
            continue
        fi

        # Count occurrences before replacement
        local count_before=$(grep -o "@${key}\b" "$output_file" | wc -l)

        # Replace @key with value in the output file, ensuring full key match
        # sed -i "s/@${key}\b/$value/g" "$output_file"
        sed -i "s|@${key}\b|$value|g" "$output_file"


        # Count occurrences after replacement
        local count_after=$(grep -o "@${key}\b" "$output_file" | wc -l)

        # Calculate how many times the key was replaced
        local replacements=$((count_before - count_after))

        # Log the result if replacements > 0
        if [[ $replacements -gt 0 ]]; then
            echo "Replaced @$key with '$value' $replacements times."
        fi

    done
}


# Function to update figure numbers
update_figures() {
    local output_file=$1
    local figure_counter=1

    # Use awk to replace ^Figure or ^ Figure with ^ Figure <number>, keeping the rest of the line
    awk -v prefix="^ Figure " '/\^ ?Figure/ {sub(/\^ ?Figure/, prefix figure_counter); figure_counter++; print; next} {print}' "$output_file" > temp_file
    mv temp_file "$output_file"
    echo "Figure numbers updated."
}

# Function to update figure numbers with two occurrences of "Figure"
double_figures() {
    local output_file=$1

    # Use sed to find lines with two occurrences of "Figure" and update them
    # Use sed to find lines with two occurrences of "Figure" and update them
    sed -i -E '/\^ Figure [0-9]+ : .+ \^ Figure :/{
        :loop
        s/\^ Figure ([0-9]+) : (.* \^ Figure) :/\^ Figure \1a : \2 \^ Figure \1b:/g
        t loop
    }' "$output_file"

    # Replace "^ Figure ^" with "^"
    sed -i -E 's/\^ Figure \^/\^/g' "$output_file"
}


# Apply changes
parse_ini "$ini_file" "$output_file"

# Update figure numbers
update_figures "$output_file"

double_figures "$output_file"

echo "Updated file saved as $output_file"
