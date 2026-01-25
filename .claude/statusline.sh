#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values
model=$(echo "$input" | jq -r '.model.display_name')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Get integer part of percentage
pct_int=${used_pct%.*}

# Calculate used tokens: (percentage * context_size) / 100
used_tokens=$(( (pct_int * context_size) / 100 ))

# Format tokens in K format
used_k=$((used_tokens / 1000))
limit_k=$((context_size / 1000))

# Create progress bar (20 characters wide)
filled=$((pct_int / 5))
empty=$((20 - filled))

bar="["
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done
bar+="]"

# Output status line
printf "%s | %s %d%% | %dK/%dK" "$model" "$bar" "$pct_int" "$used_k" "$limit_k"
